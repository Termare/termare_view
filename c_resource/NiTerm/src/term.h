
int create_ptm(
    int rows,
    int columns);
void create_subprocess(char *env,
                       char const *cmd,
                       char const *cwd,
                       char *const argv[],
                       char **envp,
                       int *pProcessId,
                       int ptmfd);
void write_to_fd(int fd, char *str);
void setNonblock(int fd);
char *get_output_from_fd(int fd);
char *getFilePathFromFd(int fd);
typedef void (*callback)(char *p);
callback dart_print;