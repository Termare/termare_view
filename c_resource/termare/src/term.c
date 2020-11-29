#include <dirent.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <termios.h>
#include <unistd.h>
#include "term.h"
#define TERMUX_UNUSED(x) x __attribute__((__unused__))
#ifdef __APPLE__
#define LACKS_PTSNAME_R
#endif
// 以防万一需要有所有的函数
void init_dart_print(callback dartprint)
{
    dart_print = dartprint;
}

//这是回调java的方法，用来报错
// static int throw_runtime_exception(JNIEnv* env, char const* message)
// {
//     jclass exClass = (*env)->FindClass(env, "java/lang/RuntimeException");
//     (*env)->ThrowNew(env, exClass, message);
//     return -1;
// }
//这个方法用来创建一个进程
//cmd  执行程序
//cwd  当前工作目录
//argv 参数，类似于["-i","-c"]

int create_ptm(
    int rows,
    int columns)
{
    //调用open这个路径会随机获得一个大于0的整形值
    // dartprint("创建终端中");
    int ptm = open("/dev/ptmx", O_RDWR | O_CLOEXEC);
    //这个值会从0依次上增
    // if (ptm < 0) return throw_runtime_exception(env, "Cannot open /dev/ptmx");
#ifdef LACKS_PTSNAME_R
    char *devname;
#else
    char devname[64];
    // dartprint("得到pst路径");
#endif
    if (grantpt(ptm) || unlockpt(ptm) ||
#ifdef LACKS_PTSNAME_R
        (devname = ptsname(ptm)) == NULL
#else
        ptsname_r(ptm, devname, sizeof(devname))
#endif
    )
    {
        // return throw_runtime_exception(env, "Cannot grantpt()/unlockpt()/ptsname_r() on /dev/ptmx");
    }
    // Enable UTF-8 mode and disable flow control to prevent Ctrl+S from locking up the display.
    struct termios tios;
    tcgetattr(ptm, &tios);
    tios.c_iflag |= IUTF8;
    tios.c_iflag &= ~(IXON | IXOFF);
    tcsetattr(ptm, TCSANOW, &tios);

    /** Set initial winsize. */
    struct winsize sz = {.ws_row = (unsigned short)rows, .ws_col = (unsigned short)columns};
    ioctl(ptm, TIOCSWINSZ, &sz);
    return ptm;
}
// int main(int argc, char** argv){
//     create_subprocess("",argv[1],argv[2],argv[3]);
//     return 0;
// }
void create_subprocess(char *env,
                       char const *cmd,
                       char const *cwd,
                       char *const argv[],
                       char **envp,
                       int *pProcessId,
                       int ptmfd)
{
#ifdef LACKS_PTSNAME_R
    char *devname;
#else
    char devname[64];
#endif

#ifdef LACKS_PTSNAME_R
    devname = ptsname(ptmfd);
#else
    ptsname_r(ptmfd, devname, sizeof(devname));
#endif
    //创建一个进程，返回是它的pid
    pid_t pid = fork();
    if (pid < 0)
    {
        // return throw_runtime_exception(env, "Fork failed");
    }
    else if (pid > 0)
    {
        *pProcessId = (int)pid;
        // int pts = open(devname, O_RDWR);
        // if (pts < 0)
        //     exit(-1);
        // //下面三个大概将stdin,stdout,stderr复制到了这个pts里面
        // //ptmx,pts pseudo terminal master and slave
        // // dup2(pts, 0);
        // dup2(pts, 1);
        // dup2(pts, 2);
        return;
    }
    else
    {
        // Clear signals which the Android java process may have blocked:
        sigset_t signals_to_unblock;
        sigfillset(&signals_to_unblock);
        sigprocmask(SIG_UNBLOCK, &signals_to_unblock, 0);

        close(ptmfd);
        setsid();
        //O_RDWR读写,devname为/dev/pts/0,1,2,3...
        int pts = open(devname, O_RDWR);
        if (pts < 0)
            exit(-1);
        //下面三个大概将stdin,stdout,stderr复制到了这个pts里面
        //ptmx,pts pseudo terminal master and slave
        dup2(pts, 0);
        dup2(pts, 1);
        dup2(pts, 2);
        //Linux的api,打开一个文件夹
        DIR *self_dir = opendir("/proc/self/fd");
        if (self_dir != NULL)
        {
            //dirfd没查到，好像把文件夹转换为文件描述符
            int self_dir_fd = dirfd(self_dir);
            struct dirent *entry;
            while ((entry = readdir(self_dir)) != NULL)
            {
                int fd = atoi(entry->d_name);
                if (fd > 2 && fd != self_dir_fd)
                    close(fd);
            }
            closedir(self_dir);
        } //清除环境变量
        // clearenv();

        if (envp)
            for (; *envp; ++envp)
                putenv(*envp);

        if (chdir(cwd) != 0)
        {
            char *error_message;
            // No need to free asprintf()-allocated memory since doing execvp() or exit() below.
            if (asprintf(&error_message, "chdir(\"%s\")", cwd) == -1)
                error_message = "chdir()";
            perror(error_message);
            fflush(stderr);
        }
        //执行程序
        execvp(cmd, argv);

        // Show terminal output about failing exec() call:
        char *error_message;
        if (asprintf(&error_message, "exec(\"%s\")", cmd) == -1)
            error_message = "exec()";
        perror(error_message);
        _exit(1);
    }
}
void write_to_fd(int fd, char *str)
{
    write(fd, str, strlen(str));
}
void setNonblock(int fd)
{
    int flag = -1;
    flag = fcntl(fd, F_GETFL); //获取当前flag
    flag |= O_NONBLOCK;        //设置新falg
    fcntl(fd, F_SETFL, flag);  //更新flag
}
char *get_output_from_fd(int fd)
{
    //动态申请空间
    char *str = (char *)malloc((4097) * sizeof(char));
    //read函数返回从fd中读取到字符的长度
    //读取的内容存进str,4096表示此次读取4096个字节，如果只读到10个则length为10
    int length = read(fd, str, 4096);
    if (length == -1)
    {
        free(str);
        return NULL;
    }
    else
    {
        str[length] = '\0';
        return str;
    }
}