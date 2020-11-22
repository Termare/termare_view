#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
import os
import sys
import time
import threading
# 适用场景,当在Python中执行sh命令时
#如os.system("sleep 10"),或者os.system("cp a b"),
# 凡是一些需要耗时的sh命令,
# 可以使用这个Python文件给你的终端附加一个等待效果
# 两种使用方式
# 1.直接在Python内部调用
# 使用import ExecWithLoading
# print(f"\033[1;31m这即将耗时3s\033[0m",end='',flush=True)
#ExecWithLoading.ExecWithLoading(f'sleep 3')
# 亦或者在Console中,直接运行./ExecWithLoading.py "sh_script"
# 以上两种方式,都将有一个简陋的等待效果,不仅如此,在这行命令运行结束之时,于这行命令的末尾会返回命令运行的时间
show = True
script = ''
list1 = ['⣿', '⣷', '⣯', '⣟', '⡿', '⣿', '⢿', '⣻', '⣽', '⣾']
# 新线程执行的代码:


def change(n):
    global show
    show = n


def setscript(sh):
    global script
    script = sh


def loop():
    os.system(script)
    change(False)


def execScript(script):
    change(True)
    setscript(script)
    t = threading.Thread(target=loop, name='LoopThread')
    t.start()
    time.sleep(0.05)
    tick = time.time()
    print("\t\t", flush=True, end="")
    i = 0
    while show:
        print(f"\010{list1[i]}", flush=True, end="")
        time.sleep(0.04)
        if i < 9:
            i += 1
        else:
            i = 0
    tick = time.time()-tick
    tick = round(tick, 1)
    print(f"\010{tick}s\n", flush=True, end="")
    t.join()


if __name__ == '__main__':
    try:
        script = str(sys.argv[1])
    except IndexError:
        print('你需要添加一行sh命令参数')
        sys.exit()
    execScript(sys.argv[1])
