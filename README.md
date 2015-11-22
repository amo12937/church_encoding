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
# Gravel のトークナイザー
# Gravel のパーサー
# Gravel のインタープリター
