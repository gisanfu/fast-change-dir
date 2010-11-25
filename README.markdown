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
- 版本控制功能(git, svn)
- 主控台(整合快速鍵) 

## Develop environment

ubuntu 9.10

## 己測試過的環境

- centos 5.2+ 
- ubuntu 9.04 
- ubuntu 9.10 
- ubuntu 10.10 

## 比較

使用這種方式，來切換資料夾，以及寫程式，

跟一般使用GUI editor或是IDE的差別。

### 缺點:

- 功能可能沒有IDE來的完整
- 小電腦或是速度不快的電腦可能會有點慢

### 優點:

- 在切換資料夾或是選取物件，如果熟悉的話，可以暫時讓眼睛休息，可以使用這個程式所提供的各種方式(請看上面的特色)來選擇項目
- 把CLI, Editor, Browser的距離拉近，而不是三個視窗
- 跨平台，免安裝(因為是在CLI的環境下，不同作業系統下，只要透過ssh protocol連進來就可以開始開發)

### 同時是優點也是缺點:

- 滑鼠用的機率會少很多
- 鍵盤會很常用
- 有兩種主要的使用方式，CLI和IDE，可以依照狀況來選擇您要的方式，例如網管可以使用CLI方式，加速CLI的操作速度，如果是程式設計師，可以使用IDE的方式

## INSTALL

1. copy scripts to unix-like /bin directory

$ sudo cp gisanfu-* /bin

2. copy bashrc.txt line to your .bashrc

$ cat bashrc.txt >> ~/.bashrc

3. restart your terminal


## CLI部份使用方式

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

## IDE部份使用方式

會有IDE的方式，剛開始的想法，主要是要擺脫CLI的一些先天的缺點，

例如我要進入一個資料夾，就必需要輸入`cd dir01` [Enter]，

如果輸入錯誤，當下是不知道的，當你打錯成`cd dir02`，這時你是必需要重打指令的，

不然你就是要輸入cd di`<tab>``<tab>`r`<tab>``<tab>`0`<tab>``<tab>`，

如果使用IDE裡面的英文選擇功能的話(abc)，就可以輸入dir02[.點]，

當你在輸入的時候，程式就會告訴你是否能直接選擇這個項目、這個項目是dir or file、等等，

另外，IDE目前己經整合大部份CLI的指令，而且做了所多的改版。

### 啟動IDE功能

*這個是舊版的IDE，大部份的功能己經納入到abc的功能裡面，會做這樣子的分類，因為後來發現，英文選擇功能(abc)，才是這個專案的精神所在

	ide
