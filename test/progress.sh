echo root@localhost:~# apt remove brotli
echo 正在读取软件包列表... 完成
echo 正在分析软件包的依赖关系树       
echo 正在读取状态信息... 完成       
echo 下列软件包将被【卸载】：
echo   brotli
echo 升级了 0 个软件包，新安装了 0 个软件包，要卸载 1 个软件包，有 0 个软件包未被升级。
echo 解压缩后将会空出 715 kB 的空间。
echo 您希望继续执行吗？ [Y/n] y
echo "\033[0;23r(正在读取数据库 ... 系统当前共安装有 24908 个文件和目录。)\033[1A"
echo "正在卸载 brotli (1.0.7-6build1) ..."
# echo "正在处理用于 man-db (2.9.1-1) 的触发器 ..."
echo "安装中"
# exitS
for i in $(seq 0 10); do
    echo "\033[24;0f"
    echo "\033[42;37mProgress : [$i%]\033[49m\033[39m [................]"
    sleep 1
done
echo -e "\033[0;24r\033[1A"