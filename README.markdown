# Fast Change Dir #

author: gisanfu

## Request environment

- BASH
-dialog

## 主要特色

- 平行切換資料夾 
- 捷徑切換資料夾 
- 2層式關鍵字定位 
- 相對名稱定位 
- 絕對位置定位 
- 多檔名暫存以及執行 
- 進入資料夾自動顯示檔案列表 
- 快速回上N層資料夾 
- 操作物件(含資料夾與檔案)，目前有定位以及模糊方式 
- 即時搜尋檔案名稱 
- 即時搜尋關鍵字 
- 即時關鍵字操作物件 
- 即時數字鍵操作物件 
- 主控台(整合快速鍵) 

## Develop environment

ubuntu 9.10

## 己使用過ok的環境

- centos 5.2+ 
- ubuntu 9.04 
- ubuntu 9.10 
- ubuntu 10.10 

## EXAMPLE

### if directory is

    aaa
       +-- dddd
    abc
    bbb
       +-- eeee
    ccc
       +-- ffff
               +-- ggggg
    		            +-- hhhhhh

### show list

$ ls -la 

	drwxr-xr-x  8 blha blha 4096 200X-XX-XX XX:XX aaa
	drwxr-xr-x  8 blha blha 4096 200X-XX-XX XX:XX abc
	drwxr-xr-x  8 blha blha 4096 200X-XX-XX XX:XX bbb
	drwxr-xr-x  8 blha blha 4096 200X-XX-XX XX:XX ccc
	drwxr-xr-x  8 blha blha 4096 200X-XX-XX XX:XX gggg
	drwxr-xr-x  8 blha blha 4096 200X-XX-XX XX:XX ggfff

### into bbb

	deee

### into aaa

	cd aaa (it's standard, you know)

### goto parent directory

	cd .. (you know)

### replace cd to d

	d aaa

[PWD]=>/aaa 

ddd/ 

### replace cd .. to g

$ g (goto parent directory)

[PWD]=>/

aaa/ bbb/ ccc/ abc/

### input several `^`keyword, if duplicate, then show them 

	d a

aaa/

abc/

### input no duplicate keyword

	d aa

### goto many directory

$ d ccc

$ d ffff

$ d ggggg

$ d hhhhhh

### return to parent dir for 4 layer

$ geeee (maximum layer is 6)

### goto the last time directory(old command is => cd -)

$ d

### goto directory by two condition

$ d gg ff

### edit position 3 file use vim

$ veee

### set groupname to environment variable

$ export groupname=project01

### add filename to vim argument list buffer

$ vf

### vim argument list buffer (vim -p aaa.txt bbb.txt ....)

$ vff

### vimdiff

$ vff vimdiff

### rm buffer file

$ vff "rm -rf"

### edit ~/gisanfu-vimlist-${groupname}.txt file

$ vfff

### add dirpoint to buffer(library is point)

$ dvv library /home/user01/zend/library

### switch to dirpoint

$ dv library

### edit ~/gisanfu-dirpoint-${groupname}.txt file

$ dvvv

## INSTALL

1. copy scripts to unix-like /bin directory

$ sudo cp gisanfu-* /bin

2. copy bashrc.txt line to your .bashrc

$ cat bashrc.txt >> ~/.bashrc

3. restart your terminal

