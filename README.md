以下、コードは CoffeeScript で記述している。

# ラムダ計算とは
[Wikipedia ラムダ計算](https://ja.wikipedia.org/wiki/%E3%83%A9%E3%83%A0%E3%83%80%E8%A8%88%E7%AE%97)  
[Wikipedia Lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus)


## 関数と関数適用の素朴な例
2つの値からその和を計算する関数を次のように書いてみる。

```coffeescript
add = (a, b) -> a + b
```

[カリー化](https://ja.wikipedia.org/wiki/%E3%82%AB%E3%83%AA%E3%83%BC%E5%8C%96)は、複数の引数を取る関数を、「引数を1つ（もとの関数の最初の引数）を受け取り「もとの関数の残りの引数を受け取り結果を返す関数」を返す関数」に変換する。  
言葉にするとややこしいが、式にするとほとんど変わらない。先の add にカリー化を施すと、次のような関数を得る；

```coffeescript
curried_add = (a) -> (b) -> a + b
```

カリー化を行う実際的なメリットとして「ある関数が何個の引数を取るか？」ということに考えを巡らせなくて良くなる、というものがある。すべての関数がカリー化されていれば、受け取る引数は常に１つであり、したがって引数に関する煩わしさを少しだけ減らすことができる。


この関数に 1 を与えると、「引数を1つ受け取りそれに1を加えた値を返す」関数が返ってくる

```coffeescript
succ = curried_add 1    # = (b) -> 1 + a
```

この関数に 2 を与えると、 2 に 1 を加えた値、つまり 3 が返ってくる。

```coffeescript
n = succ 2      # = 1 + 2
console.log n   # 3
```

内部表現や実行時間を度外視すると、以下の4つの式はどれも同じ値 3 の別表現と捉えることができる：

```coffeescript
console.log ((a) -> (b) -> a + b)(1)(2)
console.log ((b) -> 1 + b) 2
console.log 1 + 2
console.log 3
```

関数の適用を、その意味や目的を一旦忘れて、「データの表現を変えていく操作」とみなす。

```coffeescript
data =                     "((a) -> (b) -> a + b)(1)(2)"
data = conversion data   # "((b) -> 1 + b) 2"
data = conversion data   # "1 + 2"
data = conversion data   # "3"
```

ラムダ計算とはこの「操作」のことであり、ラムダ式はこの「データ」のことである。

## ラムダ式
### ラムダ式の定義
ラムダ計算の変換対象となるデータ、すなわちラムダ式がどのようなものか、以下で定義する。

#### ざっくり言うと

- Def.1. **変数** はラムダ式である
- Def.2. 変数を受け取りラムダ式を返すものはラムダ式であり、これを **ラムダ抽象** と呼ぶ
- Def.3. ラムダ式にラムダ式を適用したものはラムダ式であり、これを **関数適用** と呼ぶ

#### BNF で書くと

```
<lambda_expression>  ::= <identifier>
                       | <lambda_abstraction>
                       | <application>
<identifier>         ::= /^\w$/
<lambda_abstraction> ::= "(" "λ" <identifier> "." <lambda_expression> ")"
<application>        ::= "(" <lambda_expression> <lambda_expression> ")"
```

こんな感じ。

#### 数学的に書くと

- 変数の集合 V = {x, y, z, ... v1, v2, ..., vn, ...}
- 記号
    - λ ラムダ…ラムダ抽象の開始記号として使われる
    - . ドット…ラムダ抽象内で引数と本体の区切りとして使われる
    - () かっこ…適用順の曖昧さの排除、あるいは単に見やすさの目的で使われる

これらの変数と記号を使って、ラムダ式の集合 $\Lambda$ は次のように帰納的に定義される：

```math
\begin{eqnarray}
Def.1.&& \forall v \in V&,& v \in \Lambda \\
Def.2.&& \forall x \in V \land \forall M \in \Lambda&,& (\lambda x.M) \in \Lambda\\
Def.3.&& \forall M, N \in \Lambda&,& (M \ N) \in \Lambda
\end{eqnarray}
```

### 表記方法
上記の定義通りに記述すると、カッコやλだらけになってしまうので、以下のルールで簡易に表記する

- 一番外側のカッコは省略できる。

```math
(M \ N) = M \ N
```

- 関数適用は左結合

```math
M \ N \ P = ((M \ N)\ P)
```

- ラムダ抽象による変数束縛は出来る限り右側まで効く

```math
\lambda x.M\ N = (\lambda x.M \ N) \neq (\lambda x.M) \ N
```

- ラムダ抽象が連続する場合はまとめることが出来る（非カリー化）

```math
\lambda x.\lambda y. \lambda z.N = \lambda x \ y \ z.N
```

なお英語版 Wikipedia で変数の間に空白が省略されているが、ここでは自明な場合を除きできる限り入れている。

### 束縛変数 と 自由変数
ラムダ抽象によって束縛された変数を束縛変数、束縛されていない変数を自由変数と呼ぶ。

#### ざっくり言うと
あるラムダ式の中の自由変数の集合は、以下のルールで帰納的に定義される：

- 変数 x は自由変数である
- ラムダ抽象 \x.t の中で、t 内に出現する自由変数のうち x 以外が自由変数である
- 関数適用 t s の中で、t 内に出現する自由変数と s 内に出現する自由変数の和集合が自由変数である

#### 数学的に言うと

ラムダ式から変数の集合への関数 $FV: \Lambda \rightarrow P(V)$ が以下のように帰納的に定義される：

```math
\begin{eqnarray}
FV.1.&& FV(v) &=& \{v\} \\
FV.2.&& FV(\lambda x.t) &=& FV(t) \setminus \{x\} \\
FV.3.&& FV(t \ s) &=& FV(t) \cup FV(s)
\end{eqnarray}
```


### 置換
#### ざっくり言うと
あるラムダ式の中の自由変数を別のラムダ式に置き換えること。
ただし、この変換によって他の変数に影響があってはならない。
例えば、λx.y の y を x に変換すると λx.x となるが、この変換によって本来自由変数だった値が束縛変数になってしまっている。

#### 数学的に言うと
ここでは、ラムダ式 E の中の変数 V を R に置き換えたもののことを E[V := R] と書き表すことにする。
変換は次のルールにしたがって帰納的に行われる。（以下、x, y は 変数、M, N はラムダ式）

```math
\begin{eqnarray}
Substitution.1.&& x[x := N] &\equiv& N\\
Substitution.2.&& y[x := N] &\equiv& y \ (x \neq y の場合)\\
Substitution.3.&& (M_1 \ M_2)[x := N] &\equiv& (M_1[x := N]) \ (M_2[x := N])\\
Substitution.4.&& (\lambda x.M)[x := N] &\equiv& \lambda x.M\\
Substitution.5.&& (\lambda y.M)[x := N] &\equiv& \lambda y.(M[x := N]) \ (y \neq x かつ y \not\in FV(N))
\end{eqnarray}
```

先の例は (λx.y)[y := x] と書けるが、x ∈ FV(x) であるから Substitution.5 の条件を満たさない。
この場合は (λz.x) となってほしいが、このようなルールは英語版には書いていなかった。一応、これも加えて置換のルールとしたい。

```math
Substitution.6. (\lambda y.M)[x := N] \equiv \lambda z.(M[y := z, x := N]) \ ただし \\
y \neq x\\
y \in FV(N)\\
z \not\in FV(M)\\
z \not\in FV(N))
```


## ラムダ計算
ラムダ計算では、次の3種類の「等しさ」をベースに変換が行われる：

- α変換（引数は重要でない）
- β簡約（関数適用）
- η変換（関数の外延性）

### α変換（引数は重要でない）
次の2つはラムダ式として同じものとみなされる：

```math
\lambda x.x\\
\lambda y.y
```

以下3つのラムダ式のうち、はじめとその次は互いに等しく、最後は異なることに注意：

```math
\lambda x.\lambda x. x\\
\lambda y.\lambda x. x\\
\lambda x.\lambda y. x
```

一般に、ある変数が複数のラムダによって束縛されるときは、その変数に一番近い λ によって束縛される。

また、先に説明した置換によって変換出来るラムダ式は互いに等しい。

### β簡約（関数適用）
次の2つはラムダ式として同じものとみなされる：

```math
(\lambda x.E) \ N\\
E[x := N]
```

はじめの式はラムダ抽象 λx.E に別のラムダ式 N を適用したものであり、つぎの式はラムダ抽象の本体 E 内の自由変数 x を N に置換したものである。  
直感的には関数に引数を渡す式と渡した結果の値は同じもの、というふうに解釈できる。

### η変換（関数の外延性）
2 つのラムダ式 E, F が次を満たすとき、これらは等しいものとみなされる：

```math
\forall N \in \Lambda, \ E \ N = F \ N
```

ここでの等号は、α変換、β簡約、η変換などによって「等しさ」が言えることを表している。

具体的に言うと、次の2つは同じものである：

```math
\lambda x.f \ x\\
f
```

はじめの式に ラムダ式 N を適用すると、

```math
\begin{eqnarray}
(\lambda x.f \ x) \ N &\overset{\beta 変換}{=}& (f \ x)[x := N]\\
&=& f \ N
\end{eqnarray}
```

となって、これは第2式 f に N を適用したものと一致する。

# Church Encoding とは
さて、ラムダ計算とは「データ（= ラムダ式）の表現をいくつかのルールにしたがって変換していく操作」であった。この計算過程で現れるデータはすべてラムダ式である。こいつを使って他のプログラミング言語と同じような計算を行うには、数字や文字や配列といったデータ、それから四則演算や制御構造をラムダ式を使って表さなければならない。驚くべきことに、これらはラムダ式を使ってあらわすことが出来る。


## 数字（自然数）
数字 n を、次のように解釈する
「関数 f と 値 x を受け取り、x に対して f を n 回実行する」

具体的には、

```math
\begin{eqnarray}
0 &:=& \lambda f \ x.x\\
1 &:=& \lambda f \ x.f \ x\\
2 &:=& \lambda f \ x.f \ (f \ x)\\
3 &:=& \lambda f \ x.f \ (f \ (f \ x))\\
&...&
\end{eqnarray}
```

と続く。
ペアノ算術的にも圏論的にもこのように定義するのが自然なのだが、あまりトリビアルな定義とは言いがたい。なぜこのように定義するかは、ひとまず、他のラムダ式を定義するのに便利だから、と思って欲しい。

## 数値演算
### succ

```math
succ := \lambda n \ f \ x.f\ (n \ f \ x)
```

試しに succ 1 を計算してみると、

```math
\begin{eqnarray}
succ\ 1 &=& (\lambda n\ f\ x.f\ (n\ f\ x))\ 1\\
&\overset{\beta}{=}& (\lambda f\ x.f\ (n\ f\ x))[n := 1]\\
&\overset{\alpha}{=}& \lambda f\ x.f\ (1\ f\ x)\\
&\overset{def}{=}& \lambda f\ x.f\ ((\lambda g\ y.g\ y)\ f\ x)\\
&\overset{\beta}{=}& \lambda f\ x.f\ ((\lambda y.g\ y)[g := f]\ x)\\
&\overset{\alpha}{=}& \lambda f\ x.f\ ((\lambda y.f\ y)\ x)\\
&\overset{\beta}{=}& \lambda f\ x.f\ ((f\ y)[y := x])\\
&\overset{\alpha}{=}& \lambda f\ x.f\ (f\ x)\\
&\overset{def}{=}& 2
\end{eqnarray}
```

### add

数値 m と n の和は、n に対して succ を m 回実行することで実現される：

```math
add := \lambda m\ n.m\ succ\ n
```

### mul
掛け算 mul は、「関数 f を n 回実行する」処理を m 回実行することで実現される：

```math
\begin{eqnarray}
mul &:=& \lambda m\ n\ f\ x.m\ (n\ f)\ x\\
&\overset{\eta}{=}& \lambda m\ n\ f.m\ (n\ f)
\end{eqnarray}
```

### pow
累乗 pow は、

```math
pow := \lambda m\ n.n\ m
```

と書ける。具体的には、

```math
\begin{eqnarray}
pow\ 4\ 3\ f\ x &\overset{def}{=}& 3\ 4\ f\ x\\
&=& 4\ (2\ 4\ f)\ x\\
&=& 4\ (4\ (1\ 4\ f))\ x\\
&=& 4\ (4\ (4\ (0\ 4\ f)))\ x\\
&=& 4\ (4\ (4\ f))\ x\\
&=& 4\ (16\ f)\ x\\
&=& 64\ f\ x\\
\end{eqnarray}
```

外延性より、 pow 4 3 = 64 = 4^3 が言えた。

### pred
次の数を与える succ に比べ、前の数を与える pred はずっと難しい。まず、次のラムダ式を考える。

```math
T := \lambda g\ h.h\ (g\ f)
```

こいつを、ラムダ式 F に対して何回か適用し、その挙動を見てみる。T^n F で T (T (...n回...(T F)...) をあらわす。

```math
\begin{eqnarray}
T\ F &=& (\lambda g\ h.h\ (g\ f))\ F\\
&=&\lambda h.h\ (F\ f)\\
T\ (T\ F) &=& T\ (\lambda h.h\ (F\ f))\\
&=& (\lambda g\ h.h\ (g\ f))\ (\lambda h.h\ (F\ f))\\
&\overset{\alpha}{=}& (\lambda g\ h.h\ (g\ f))\ (\lambda k.k\ (F\ f))\\
&=& \lambda h.h\ ((\lambda k.k\ (F\ f))\ f)\\
&=& \lambda h.h\ (f\ (F\ f))\\
T\ (T\ (T\ F)) &=& T\ (\lambda h.h\ (f\ (F\ f)))\\
&=& (\lambda g\ h.h\ (g\ f))\ (\lambda k.k\ (f\ (F\ f)))\\
&=& \lambda h.h\ ((\lambda k.k\ (f\ (F\ f)))\ f)\\
&=& \lambda h.h\ (f\ (f\ (F\ f)))\\
&\dots&\\
T^n\ F &=& \lambda h.h\ (f^{n - 1}\ (F\ f))
\end{eqnarray}
```

T は、F に n 回適用すると、「F f に f を n - 1 回適用させた関数」（を h に渡す関数）を返す。F f が x と評価され、h E が E と評価されれば、ちょうど n の前の数 n - 1 を得たことになる。

```math
\begin{eqnarray}
T^n\ (\lambda u.x)\ (\lambda v.v) &=& (\lambda h.h\ (f^{n - 1}\ ((\lambda u.x)\ f)))\ (\lambda v.v)\\
&=& (\lambda h.h\ (f^{n - 1}\ x))\ (\lambda v.v)\\
&=& (\lambda v.v)\ (f^{n - 1}\ x)\\
&=& (f^{n - 1}\ x)\\
\end{eqnarray}
```

T^n F はラムダ式の記法で n T F であるから、最終的に以下の式を得る。

```math
pred := \lambda n\ f\ x.n\ (\lambda g\ h.h\ (g\ f))\ (\lambda u.x)\ (\lambda v.v)
```

なお pred 0 は -1 ではなく 0 になるので注意

```math
\begin{eqnarray}
pred\ 0\ f\ x &=& 0\ (\lambda g\ h.h\ (g\ f))\ (\lambda u.x)\ (\lambda v.v)\\
&=& (\lambda u.x)\ (\lambda v.v)\\
&=& x\\
&=& 0\ f\ x
\end{eqnarray}
```

### sub
pred が出来れば sub は簡単

```math
sub := \lambda m\ n.n\ pred\ m
```

m > n の場合は m - n を計算し、そうでない場合は 0 を返す。

## 真偽値
真偽値は、次のように定義される：

```math
\begin{eqnarray}
true &:=& \lambda x\ y.x\\
false &:=& \lambda x\ y.y
\end{eqnarray}
```

false は、α変換によって 0 と等しくなることに注意されたい。  
これらを使って、and, or なども定義することができる

```math
\begin{eqnarray}
and &:=& \lambda p\ q.p\ q\ false\\
or &:=& \lambda p\ q.p\ true\ q\\
not &:=& \lambda p\ x\ y.p\ y\ x\\
if &:=& \lambda p\ then\ else.p\ then\ else\\
\end{eqnarray}
```

ただし if は、関数の外延性によりなにもないのと同じである。(if a b c d e... はβ簡約により a b c d e... に変換できる）

数値に関する真偽判定関数を定義する

```math
\begin{eqnarray}
isZero &:=& \lambda n.n\ (\lambda x.false)\ true\\
leq &:=& \lambda m\ n.isZero\ (sub\ m\ n)\\
geq &:=& \lambda m\ n.leq\ n\ m\\
eq &:=& \lambda m\ n.and\ (leq\ m\ n)\ (geq\ m\ n)
\end{eqnarray}
```

## リスト
### 対
次に、2つのラムダ式の「対」を定義する。対 (a, b) は、a を返す関数 first と b を返す関数 second とセットで定義される。

```math
\begin{eqnarray}
pair &:=& \lambda a\ b\ p.p\ a\ b\\
first &:=& \lambda p.p\ true\\
second &:=& \lambda p.p\ false
\end{eqnarray}
```

### リスト
対が出来れば、リストは簡単である。値とリストからリストを生成する cons, リストから先頭の値を取り出す head, 先頭以外の残りを取り出す tail はそれぞれ pair, first, second と同じである。  
リストの終端を示す nil は、いろいろな定義があるが、ここでは英語版 wikipedia の定義に従う。nil の場合に true を返す関数 isnil も用意する。

```math
\begin{eqnarray}
cons &:=& pair\\
head &:=& first\\
tail &:=& second\\
nil &:=& \lambda x.true\\
isnil &:=& \lambda list.list\ (\lambda h\ t.false)
\end{eqnarray}
```

### 文字列
文字列とは、文字のリストであり、文字は数字によって添字付けられた記号である。この添字は例えば Unicode の番号であり、これをもって文字の代替とすることができるから、文字列とは結局数字のリストと考えることができる。したがって、これはラムダ式で表現可能である

## 再帰
### 不動点
代入構文 := は便宜上使っているだけで本来のラムダ式の記法ではない。したがって、階乗を計算する次の式は無効である

```math
f := \lambda n.isZero\ n\ 1\ (mul\ n\ (f\ (pred\ n)))
```

内部の f は、自由変数であり、これでは再帰関数を表現したことにならない。  
ラムダ式を使って再帰を実現するために、式を次のように書き換える。

```math
g := \lambda f\ n.isZero\ n\ 1\ (mul\ n\ (f\ (pred\ n)))
```

g にあるラムダ式 F を適用して、再帰的に階乗の計算を行いたい。

```math
\begin{eqnarray}
g\ F &:=& (\lambda f\ n.isZero\ n\ 1\ (mul\ n\ (f\ (pred\ n))))\ F\\
&=& \lambda\ n.isZero\ n\ 1\ (mul\ n\ (F\ (pred\ n)))
\end{eqnarray}
```

F が再び λn.isZero n 1 (mul n(F (pred n))) という形をしていれば、これに pred n を渡すことで階乗の計算が可能となる。  
したがって、再帰を行うには次を満たすラムダ式 F を見つければ良いということになる

```math
F = g\ F
```

この F を g の不動点と呼ぶ

### Y コンビネータ
任意の関数 g の不動点を与えるラムダ式として、以下の式が知られている

```math
Y := \lambda f.(\lambda x.f\ (x\ x))\ (\lambda x.f\ (x\ x))
```

F = Y g として、これを評価してみる

```math
\begin{eqnarray}
F = Y\ g &=& (\lambda f.(\lambda x.f\ (x\ x))\ (\lambda x.f\ (x\ x)))\ g\\
&=& ((\lambda x.f\ (x\ x))\ (\lambda x.f\ (x\ x)))[f := g]\\
&=& (\lambda x.g\ (x\ x))\ (\lambda x.g\ (x\ x))\\
&=& (g\ (x\ x))[x := (\lambda x.g\ (x\ x))]\\
&=& g\ ((\lambda x.g\ (x\ x))\ (\lambda x.g\ (x\ x)))\\
&=& g\ (\lambda f.(\lambda x.f\ (x\ x))\ (\lambda x.f\ (x\ x)))[f := g]\\
&=& g\ (Y\ g) = g\ F
\end{eqnarray}
```

したがって、F = Y g は g の不動点である。

Y コンビネータが実際に計算される様子を追ってみよう。最初と最後だけ少し丁寧に書いた。

```math
\begin{eqnarray}
fact &:=& \lambda f\ n.isZero\ n\ 1\ (mul\ n\ (f\ (pred\ n)))\\
Y\ fact\ 5 &=& (\lambda f.(\lambda x.f\ (x\ x))\ (\lambda x.f\ (x\ x)))\ fact\ 5\\
&=&((\lambda x.f\ (x\ x))\ (\lambda x.f\ (x\ x)))[f := fact]\ 5\\
&=&(\lambda x.fact\ (x\ x))\ (\lambda x.fact\ (x\ x))\ 5\\
&=&fact\ ((\lambda x.fact\ (x\ x))\ (\lambda x.fact\ (x\ x)))\ 5\\
&=&fact\ (Y\ fact)\ 5\\
&=&(\lambda f\ n.isZero\ n\ 1\ (mul\ n\ (f\ (pred\ n))))\ (Y\ fact)\ 5\\
&=&(\lambda n.isZero\ n\ 1\ (mul\ n\ (Y\ fact\ (pred\ n))))\ 5\\
&=&isZero\ 5\ 1\ (mul\ 5\ (Y\ fact\ (pred\ 5)))\\
&=&mul\ 5\ (Y\ fact\ (pred\ 5))\\
&=&mul\ 5\ (Y\ fact\ 4)\\
&=&mul\ 5\ (mul\ 4\ (Y\ fact\ 3))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ (Y\ fact\ 2)))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ (mul\ 2\ (Y\ fact\ 1))))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ (mul\ 2\ (mul\ 1\ (Y\ fact\ 0)))))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ (mul\ 2\ (mul\ 1\ ((\lambda f.(\lambda x.f\ (x\ x))\ (\lambda x.f\ (x\ x)))\ fact\ 0)))))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ (mul\ 2\ (mul\ 1\ ((\lambda x.fact\ (x\ x))\ (\lambda x.fact\ (x\ x))\ 0))))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ (mul\ 2\ (mul\ 1\ (fact\ (Y\ fact)\ 0)))))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ (mul\ 2\ (mul\ 1\ ((\lambda f\ n.isZero\ n\ 1\ (mul\ n\ (f\ (pred\ n))))\ (Y\ fact)\ 0)))))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ (mul\ 2\ (mul\ 1\ ((\lambda n.isZero\ n\ 1\ (mul\ n\ (Y\ fact\ (pred\ n))))\ 0)))))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ (mul\ 2\ (mul\ 1\ (isZero\ 0\ 1\ (mul\ 0\ (Y\ fact\ (pred\ 0))))))))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ (mul\ 2\ (mul\ 1\ 1))))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ (mul\ 2\ 1)))\\
&=&mul\ 5\ (mul\ 4\ (mul\ 3\ 2))\\
&=&mul\ 5\ (mul\ 4\ 6)\\
&=&mul\ 5\ 24\\
&=&120
\end{eqnarray}
```

# 自作言語 Gravel
Church Encoding は面白そうで、文法が簡単（ラムダ式と適用しかない）なので、これを解釈し実行するインタープリターを作ってみた。  
言語名は、perl → ruby の流れに乗りペリドットとかにしたかったが宝石名を付けるのは大仰だったので「砂利とかでいいか」と思い砂利の英語を調べたら存外良い響きだったことに由来する。

Gravel の特徴、出来ること、出来ないことは以下のとおり

- CoffeeScript で書いてあり、web 上で実行可能
    - 1行程度のコードなら 字句解析 1 msec 以下, 構文解析 1 msec 以下, 実行数十〜200 msec 程度
- Church Encoding からの変更点
    - 代入構文 := を実装
    - λの代わりにバックスラッシュ \ をラムダ抽象の開始記号にしている
- コメントを記述できる
    - # 一行コメント
    - #- ブロックコメント -#
- 評価戦略は遅延評価
    - ただし、評価値が数値か数値を引数にとる関数の場合は、その引数に当たるラムダ式が数値化どうかを先にチェックしている
        - 例えば succ N は通常 \f x.f (N f x) と評価され、ラムダ式 f と x の適用を待つが、N が数値（例えば 5）だった場合には計算結果（6）を返す。
- 未実装（気が向いたら頑張ります）
    - 入出力周り
        - コンソール的なのがあるだけで、実行途中で入力を待ったりは出来ない。
    - モジュール機能
        - 全部グローバル変数
    - インポート機能
        - リロードしたら消える
    - 負の数、有理数、実数
        - 自分ピタゴラス学派なんで…
    - 貧弱な標準ライブラリ
        - 文字列処理系は殆ど無い
        - ご自分でお作りくださいというスタンス
    - などなど

## BNF
BNF は以下のとおり

```
S                    ::= (<application> "\n")+
<application>        ::= <expr>+
<expr>               ::= "(" <application> ")"
                       | <lambda_abstraction>
                       | <definition>
                       | <constant>
<lambda_abstraction> ::= "\" <identifier>+ "." <application>
<definition>         ::= <identifier> ":=" <application>
<constant>           ::= <identifier>
                       | <natural_number>
                       | <string>
<identifier>         ::= /^(?:[_a-zA-Z]\w*|[!$%&*+/<=>?@^|\-~]+)$/
<natural_number>     ::= /^(?:0|[1-9]\d*)$/
<string>             ::= /^(?:"((?:[^"\\]|\\.)*)"|'((?:[^'\\]|\\.)*)')/
```

- ソースコードは、適用（`<application>`）の列からなる
- `<application>` は、ラムダ式（`<expr>`） の列からなる
- `<expr>` は、以下の4種類のいずれかである
    - 括弧付けられた適用（`<application>`）
    - ラムダ抽象（`<lambda_abstraction>`）
    - 定義式（`<definition>`）
    - 変数（`<constant>`）
- `<lambda_abstraction>` は、
    - はじめに開始記号（`\`）があり
    - 引数（`<identifier>`）の列があり
    - 本体の開始記号（`.`）があり
    - 本体は適用（`<application>`）である
- `<definition>` は、
    - 識別子（`<identifier>`）があり、
    - 本体の開始記号（`:=`）があり、
    - 本体は適用（`<application>`）である
- `<constant>` は、次の3種がある
    - `<identifier>` ... `/^(?:[_a-zA-Z]\w*|[!$%&*+/<=>?@^|\-~]+)$/`
    - `<natural_number>` ... `/^(?:0|[1-9]\d*)$/`
    - `<string>` ... `/^(?:"((?:[^"\\]|\\.)*)"|'((?:[^'\\]|\\.)*)')/`

# Gravel の Lexer
Lexer（字句解析器）の役割は、文字列であるソースコードをその言語として意味のある単位（トークン）に分解することである。

例えば、以下の CoffeeScript の式：

```coffeescript
add = (a) -> (b) -> a + b
```

は、このように分解される：

```coffeescript

[ [ 'IDENTIFIER',
    'add',
    { first_line: 0, first_column: 0, last_line: 0, last_column: 2 },
    variable: true,
    spaced: true ],
  [ '=',
    '=',
    { first_line: 0, first_column: 4, last_line: 0, last_column: 4 },
    spaced: true ],
  [ 'PARAM_START',
    '(',
    { first_line: 0, first_column: 6, last_line: 0, last_column: 6 } ],
  [ 'IDENTIFIER',
    'a',
    { first_line: 0, first_column: 7, last_line: 0, last_column: 7 },
    variable: true ],
  [ 'PARAM_END',
    ')',
    { first_line: 0, first_column: 8, last_line: 0, last_column: 8 },
    spaced: true ],
  [ '->',
    '->',
    { first_line: 0, first_column: 10, last_line: 0, last_column: 11 },
    spaced: true ],
  [ 'INDENT',
    2,  
    { first_line: 0, first_column: 11, last_line: 0, last_column: 11 },
    generated: true,
    origin: [ '->', '->', [Object], spaced: true ] ],
  [ 'PARAM_START',
    '(',
    { first_line: 0, first_column: 13, last_line: 0, last_column: 13 } ],
  [ 'IDENTIFIER',
    'b',
    { first_line: 0, first_column: 14, last_line: 0, last_column: 14 },
    variable: true ],
  [ 'PARAM_END',
    ')',
    { first_line: 0, first_column: 15, last_line: 0, last_column: 15 },
    spaced: true ],
  [ '->',
    '->',
    { first_line: 0, first_column: 17, last_line: 0, last_column: 18 },
    spaced: true ],
  [ 'INDENT',
    2,  
    { first_line: 0, first_column: 18, last_line: 0, last_column: 18 },
    generated: true,
    origin: [ '->', '->', [Object], spaced: true ] ],
  [ 'IDENTIFIER',
    'a',
    { first_line: 0, first_column: 20, last_line: 0, last_column: 20 },
    variable: true,
    spaced: true ],
  [ '+',
    '+',
    { first_line: 0, first_column: 22, last_line: 0, last_column: 22 },
    spaced: true ],
  [ 'IDENTIFIER',
    'b',
    { first_line: 0, first_column: 24, last_line: 0, last_column: 24 },
    variable: true ],
  [ 'OUTDENT',
    2,  
    { first_line: 0, first_column: 24, last_line: 0, last_column: 24 },
    generated: true,
    origin: [ '->', '->', [Object], spaced: true ] ],
  [ 'OUTDENT',
    2,  
    { first_line: 0, first_column: 24, last_line: 0, last_column: 24 },
    generated: true,
    origin: [ '->', '->', [Object], spaced: true ] ],
  [ 'TERMINATOR',
    '\n',
    { first_line: 0, first_column: 25, last_line: 0, last_column: 25 } ] ]
```

括弧が正しく閉じられていなかったり、インデントが合っていなかったり、コメントが正しく閉じられて居なかったりすると、ここでエラーとなる。

Gravel では、[CoffeeScriptのLexer](https://github.com/jashkenas/coffeescript/blob/1.10.0/src/lexer.coffee) を参考に作っている。

## 大まかな流れ
コードを先頭から読んでいき、読み終わった文字列をカウントしていく。

https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/tokenizer.coffee#L44-L52

コメントや空白は文字数としてはカウントするがトークンとしてはカウントしない。
予約語や識別子は文字数としてカウントし、かつトークンとしてもカウントしていく。

```coffeescript
  while context.chunk = code[i..]
    consumed = commentToken(context)       or
               whitespaceToken(context)    or
               lineToken(context)          or
               literalToken(context)       or
               identifierToken(context)    or
               naturalNumberToken(context) or
               stringToken(context)        or
               errorToken(context)
```

- [commentToken](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/tokenizer.coffee#L64-L69)
    - # 一行コメント や #- ブロックコメント -# を判定し、これらを除去する。
- [whitespaceToken](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/tokenizer.coffee#L72-L75)
    - 改行を除く空白を判定し、これらを除去する。
- [lineToken](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/tokenizer.coffee#L77-L81)
    - 改行を判定する。この際、
        - 閉じられていない括弧がある場合は次の行も一つの式として認識する
        - すべての括弧が閉じられていた場合は、式の終了をあらわす TOKEN.LINE_BREAK を差し挟む
- [literalToken](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/tokenizer.coffee#L84-L112)
    - literal とか言っておいて演算子や括弧等を判定する（そのうちリネームします m(__)m）。Gravel の 演算子は以下のとおり
        - `\` ... `LAMBDA`
        - `.` ... `LAMBDA_BODY`
        - `(` ... `BRACKETS_OPEN`
        - `)` ... `BRACKETS_CLOSE`
        - `:=` ... `DEF_OP`
    - 括弧の対応が取れていない場合ここで TOKEN.ERROR.UNMATCHED_BRACKET エラーが出る。
- [identifierToken](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/tokenizer.coffee#L115-L118)
    - 識別子を判定する
    - Gravel の識別子は、文字列 `/[_a-zA-Z]\w*/` と いくつかの記号列 /[!$%&*+/<=>?@^|\-~]+/ で、文字と記号が混ざったものは認識されない。
    - 例
        - add, mul, Y...
        - +, *, =, ...
- [naturalNumberToken](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/tokenizer.coffee#L121-L124)
    - 自然数リテラルに反応する
    - 0 は自然数
- [stringToken](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/tokenizer.coffee#L127-L131)
    - 文字列リテラルに反応する
- [errorToken](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/tokenizer.coffee#L134-L137)
    - 上記のどれにもマッチしない文字列は、空白までをひとまとめにして TOKEN.ERROR.UNKNOWN_TOKEN を出す。

tokenizer.tokenize によってソースコードの文字列が読み込まれ、トークンの配列（正確には rewind 出来る iterator オブジェクト）を返す。このオブジェクトはパーサーに渡され、構文解析される。

# Gravel のParser
Parser（構文解析器）の役割は、トークンの列が言語の文法に沿って並んでいるかをチェックするとともに、抽象構文木と呼ばれるツリー構造のオブジェクトを生成する。

## parse
Gravel では、BNF と対応するように parser を組み立てている。

```
S                    ::= (<application> "\n")+
<application>        ::= <expr>+
<expr>               ::= "(" <application> ")"
                       | <lambda_abstraction>
                       | <definition>
                       | <constant>
<lambda_abstraction> ::= "\" <identifier>+ "." <application>
<definition>         ::= <identifier> ":=" <application>
<constant>           ::= <identifier>
                       | <natural_number>
                       | <string>
<identifier>         ::= /^(?:[_a-zA-Z]\w*|[!$%&*+/<=>?@^|\-~]+)$/
<natural_number>     ::= /^(?:0|[1-9]\d*)$/
<string>             ::= /^(?:"((?:[^"\\]|\\.)*)"|'((?:[^'\\]|\\.)*)')/
```

### ソースコードは、適用（`<application>`）の列からなる
[parseMultiline](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L27-L40)

- ループの中で parseApplication を呼び出し、適用リストに加えていく
- TOKEN.LINE_BREAK があれば、パースを続ける
- TOKEN.LINE_BREAK が無い = コードが終了したので、適用リストを返却する。

### `<application>` は、ラムダ式（`<expr>`） の列からなる
[parseApplication](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L42-L56)

- ループの中で parseExpr を呼び出し、ラムダ式リストに加えていく
- parseExpr が null を返した時点でループを抜ける
- ラムダ式リストが空の場合、parseApplication 自体は null を返す
- ラムダ式が 1 つだけの場合、それを返す
- ラムダ式が 2 つ以上の場合、例えば [a, b, c, d] の場合、[[[a, b], c], d] と、2分木にし、これを適用として返す。

### `<expr>` は、以下の4種類のいずれかである
- 括弧付けられた適用（`<application>`）
- ラムダ抽象（`<lambda_abstraction>`）
- 定義式（`<definition>`）
- 変数（`<constant>`）

[parseExpr](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L58-L62)

- そのまんま、parseApplicationWithBrackets, parseLambdaAbstraction, parseDefinition, parseConstant のいずれかを返す

### 括弧付けられた適用
[parseApplicationWithBrackets](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L64-L75)

- トークンを一つ取り出し、TOKEN.BRACKETS_OPEN かどうかを判定する
    - false なら、lexer を巻き戻して null を返却する（つまり、括弧付き適用はなかったということ）
- parseApplication を呼び出し、適用があるかどうかを判定する
    - 無かった場合、「括弧はあるのに適用が無かった」として、エラーを登録する
    - lexer を巻き戻し、null を返却する
- トークンを一つ取り出し、TOKEN.BRACKETS_CLOSE かどうかを判定する
    - false なら、「括弧が閉じられていない」というエラーを登録する
    - lexer を巻き戻し、null を返却する
- 括弧、適用、括弧閉じが正しく読み込まれた場合、適用の部分を返す（括弧は抽象構文木の段階では不要である）

### `<lambda_abstraction>` は、はじめに開始記号（`\`）があり…
[parseLambdaAbstraction](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L77-L102)

- トークンを一つ取り出し、TOKEN.LAMBDA（`\`） かどうかを判定する
    - false なら、ラムダ抽象ではないので、lexer を巻き戻して null を返却する
- トークンが TOKEN.IDENTIFIER でなくなるまで、トークンを取り出す
    - 1 つも TOKEN.IDENTIFIER が無かった場合、「引数は最低1個必要」というエラーを登録する
    - 1 つ以上の TOKEN.IDENTIFIER の直後が TOKEN.LAMBDA_BODY（`.`）で無かった場合、「ラムダ抽象の本体が必要」というエラーを登録する
- ラムダ抽象の本体は parseApplication でパースする
    - parseApplication が null を返した場合、「ラムダ抽象の本体が必要」というエラーを登録する
- `\`、引数、`.`、本体が正しく読み込まれた場合、カリー化を行いながら抽象構文木を構築し、これを返却する

### `<definition>` は、識別子（`<identifier>`）があり…
[parseDefinition](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L104-L116)

- これも基本的な流れは一緒
- トークンを 1 つ取り出し、TOKEN.IDENTIFIER かどうかを判定する
    - false なら 定義 ではないので lexer を巻き戻して null を返却する
- トークンを 1 つ取り出し、TOKEN.DEF_OP（`:=`） かどうかを判定する
    - false なら 定義 ではないので lexer を巻き戻して null を返却する
- 定義の本体は parseApplication でパースする
    - null が帰ってきた場合「定義の本体が必要」というエラーを登録する
- 変数名、`:=`、本体が正しく読み込まれた場合、抽象構文機を構築してこれを返却する

### `<constant>` は、次の3種がある
- `<identifier>` ... `/^(?:[_a-zA-Z]\w*|[!$%&*+/<=>?@^|\-~]+)$/`
- `<natural_number>` ... `/^(?:0|[1-9]\d*)$/`
- `<string>` ... `/^(?:"((?:[^"\\]|\\.)*)"|'((?:[^'\\]|\\.)*)')/`

[parseConstant](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L118-L125)

- トークンを 1 つ取り出し、TOKEN.IDENTIFIER, TOKEN.NUMBER.NATURAL, TOKEN.STRING のいずれかを判定する
- どれでもなければ、lexer を巻き戻して null を返却する

## 抽象構文木の node
Parser によって生成される抽象構文木は、以下の 7 種類のノードから成る

- [listNode](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L131-L134)
    - 適用の配列を保持する
- [applicationNode](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L136-L140)
    - 関数（left）と 引数（right）を保持し、left に right を適用する node をあらわす
- [lambdaAbstractionNode](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L142-L146)
    - 引数（arg）と本体（body）を保持し、カリー化されたラムダ抽象をあらわす
- [definitionNode](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L148-L152)
    - 変数名（name）と本体（body）を保持し、変数の定義をあらわす
- [identifierNode](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L154-L157)
- [naturalNumberNode](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L159-L162)
- [stringNode](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/parser.coffee#L164-L168)
    - それぞれの値を保持する。葉ノード。

# Gravel の Interpreter
Gravel の Interpreter は、抽象構文木を受け取り、適用可能なオブジェクト Runner を返す。

```math
interprete: AST \longrightarrow Runner
```

## 適用可能なオブジェクト Runner
Runner は、次の 3 つのメソッドを持つ

```math
\begin{eqnarray}
constructor:&AST \times Env &\longrightarrow& Runner\\
toString:& Runner &\longrightarrow& String\\
run:& Runner \times FutureEval &\longrightarrow& Runner
\end{eqnarray}
```

- 抽象構文木と現在の環境を引数に取る constructor
    - 実際には Interpreter が環境を保持しており、Runner のコンストラクタには Interpreter を渡す。
- 自身の表現を返す toString
    - 例えば NumberRunner はその数字を、LambdaAbstractionRunner はラムダ抽象の表現を返す。
- 「将来評価されるオブジェクト」 FutureEval を受け取り、自身への引数として適用する run

## 将来評価されるオブジェクト FutureEval
FutureEval は抽象構文木と Interpreter を受け取り、get メソッドを持つオブジェクトを返す。
get メソッドは、将来必要になった時に呼び出され、評価はその最初の一度目で行われる。

```math
\begin{eqnarray}
constructor:&AST \times Interpreter &\longrightarrow& FutureEval\\
get:& FutureEval &\longrightarrow& Runner\\
\end{eqnarray}
```

## 環境 Env
環境と Runner は 1対多で対応しており、変数の名前解決に使われる。

ラムダ抽象にラムダ式が適用されると、ラムダ抽象が保持する環境から子環境を生成して ラムダ式を引数に束縛する。
これにより、ラムダ抽象が定義された環境の変数が中で使えるようになる（レキシカルスコープ）。

Gravel は CoffeeScript で実装しており、Env の親子関係は JavaScript の prototype チェーンを使って実現している（むしろこれを利用したいために CoffeeScript を選んだ）。
その結果、煩わしい if 文や parent をたどる処理を加えること無く、child.x を見るだけで parent.x も全部探してくれるというシンプルな実装になった。

→ [シンプルな実装](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/env_manager.coffee)

## 評価例：`(\x y.x) 1 2`

- `(\x y.x)` と 現在の環境 `global` から Runner `r1` が生成される
- 1 と現在の interpreter から FutureEval `fe1` が生成される
- `r1.run(fe1)` が実行される
    - r1 に紐付けられた環境 `global` の子環境 `env1` が生成される
    - `env1.x = 1`
    - `(\x y.x)` の本体 `\y.x` が評価される。
    - 評価の結果 `\y.x` は ラムダ抽象であったから、これと `env1` から Runner `r2` が生成される
- 2 と現在の interpreter から FutureEval `fe2` が生成される
- `r2.run(fe2)` が実行される
    - r2 に紐付けられた環境 `env1` の子環境 `env2` が生成される
    - `env2.y = 2`
    - `\y.x` の本体 `x` が評価される。
    - 評価の結果 `x` は変数であったから、現在の環境 `env2` から x が検索される
    - env2 は x を持っていないので、 env2.__proto__.x = env1.x が検索される
    - env1.x は 1 であったから、これと現在の環境 `env2` から Runner `r3 が生成される
- 最終的な評価結果は `r3` であり、これを表示する際に toString が呼ばれる
- toString は文字として "1" を返す

## 標準ライブラリ
少ないが、一応[標準ライブラリ](https://github.com/amo12937/gravel/blob/v1.0.0/src/scripts/visitor/stdlib.coffee#L27-L55)も用意している。

- nil は特別な Runner を用意しており、何を適用しても必ず nil を返す。
    - 何を適用されても自分自身を返す、というラムダ式は `Y true` という形であらわす事ができる。
- isnil で nil だったら true ほかは false というラムダ式を作りたかったが、 `Y true` に対する `isnil` はどうしても作れなかった
    - 仕方ないので、こちらも特別な Runner を用意し、引数が NilRunner だったら true, そうでなかったら false を返すようにしている。

# Gravel コンソール
Gravel を Web 上で実行するコンソールも作った。

[Gravel コンソール](http://amo12937.github.io/gravel_web/)

- help <name> で、文法などを参照することが出来る。
    - help BNF
        - BNF を見ることが出来る
    - help application
        - 適用のラムダ式を見ることが出来る
    - help labda
        - ラムダ抽象のラムダ式を見ることが出来る
    - definition
        - 定義のラムダ式を見ることが出来る
    - defined
        - 標準ライブラリの一覧を見ることが出来る

## Gravel で階乗
```
> fact 5
= 120
```

## Gravel で Hello World
文字列を評価すると、評価値がそのまま返ってくるので、

```
> "Hello World"
= "Hello World"
```

うん、まぁ。

## Gravel で Quine
未定義の変数はその変数名が評価値となる：

```
> Quine
= Quine
```

はい。

## Gravel で fizz buzz
まず、余りを返す関数は作っていないのでこれを作る。

```
> % := \m n.sub m (* n (div m n))
= OK: %
```

次に、n を受け取り、fizz か buzz か fizzbuzz か n を返す関数を作る。

```
> fb := \n. isZero (% n 15) "fizzbuzz" (isZero (% n 3) "fizz" (isZero (% n 5) "buzz" n))
= OK: fb
> fb 1
= 1
> fb 3
= "fizz"
> fb 5
= "buzz"
> fb 15
= "fizzbuzz"
```

次に、n を受け取り 1 〜 n までの値に fizzbuzz を適用する関数を作る。これには、Y コンビネータを用いる。

```
> fizzbuzz := Y (\f r n.isZero n r (f (pair (fb n) r) (pred n))) nil
= OK: fizzbuzz
> fizzbuzz 16
= \p.((p a) b)
```

しまった配列の中身を表示する仕組みを作っていなかった。

```
> a := fizzbuzz 16
= OK: a
> head a
= 1
> head (tail a)
= 2
> head (tail (tail a))
= "fizz"
> head (tail (tail (tail a)))
= 4
> head (tail (tail (tail (tail a))))
= "buzz"
...
```

こんな感じ。


# 終わりに
本当はコンパイラを作りたかったが、勉強不足により断念。そのうち挑戦したい。
