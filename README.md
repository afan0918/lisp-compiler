### 介紹
一個lisp編譯器。

使用lex和yacc來實現，結構大致讓跟講義差不多。

做完的部分:
* Syntax Validation
* Print
* Numerical Operations
* Logical Operations
* if Expression
* Variable Definition
* Function
* Named Function
* Type Checking

未完成:
* Recursion 
* Nested Function 
* First-class Function
### 使用方法:

在當前目錄下輸入
```
./test.sh
```
理論上就會自動把test_data內的內容掃過一遍，並在result此檔案中顯示。

```
syntax error
syntax error
1
2
3
4
0
-123
456
133
2
-1
-256
...
```

如果不行的話，可以試試看

```
flex final.l
yacc -d final.y
g++ lex.yy.c y.tab.c -ll
```
一定要用g++是因為我的struct是用cpp的格式寫的哈哈哈，所以gcc會編譯不過，哇哇我是壞小孩。

會得到一個a.out，然後可以

```
./a.out < 要輸入的檔案
```

### 思路

我一開始都是在看別人的專案，畢竟lisp有點大，找不太到思路。

基本上大家的做法可以分成兩種

#### 在AST解析規則的時候做完運算

這種很酷，但我不太行，可能是我太菜就思路跟不上，也沒有修改的能力，試著做一下就放棄了。

#### 在解析規則的時候另外建一棵AST

大概看到了三個這類型的做法的專案，感覺比較適合我(?)，畢竟遍歷的時候只要照著規則跑就好，缺點是跟別人討論的時候就會欸幹你怎麼也參考那個，我回去馬上多修改一點，粗事了。

我做的事情大概就是以自己的理解重寫一遍並試圖通過加分題，只有五百多行應該似業界最短(?)，遞迴的部份我寫了大概一整個周末，然後發現結構對不上退回原點就不想動了，bool的部分原本是用bool型別來接，但後來我發現哭阿，int+bool才不會報型別錯誤，就乾脆在建ast的時候在節點做好標記，然後運算會變成bool的做法也把is_bool這個變數向上傳遞，就解掉了，啊我一開始還沒有考慮到function的部分，所以有特別改，然後發現改完之後寫遞迴更麻煩，爆炸。

最後一直卡遞迴就去寫圖學了(x)

https://github.com/afan0918/computer-graphics

### 參考專案

https://github.com/Zane2453/Mini-LISP-interpreter_Lex-Yacc

https://github.com/q23175401/complier-final-miniLisp

其實還有很多其他的，但主要就這兩個。