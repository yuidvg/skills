# 販路のチェックリスト

調べるときは、ここに載っている全サイトを実際に開く。そのうえで、品目に合う専門店を足す（最後の節を参照）。

注記は、**2026-11-20（JST）に実際に開いて確かめた結果**をもとにしたヒントで、決まった手順ではない。サイトは変わるので、合わなければ別の方法を試し、ここを直す。

- 試した順番：curl（既定の設定）→ ヘッドレスのブラウザ（agent-browser の既定）→ 画面ありの通常のブラウザ（Claude の内蔵ブラウザ）
- 見出しの（ ）は、個別ページまで読めた方法を表す。
  - **curl可**：HTMLを取るだけで読めた。
  - **ブラウザ要**：JSで描画されるので、ヘッドレスでも構わないのでブラウザが要る。
  - **通常のブラウザ要**：curl もヘッドレスも拒否されたが、画面ありの通常のブラウザでは読めた。
  - **条件付き**：一部しか読めない。
  - **停止中**：その日は止まっていた。
  - **不可**：どの方法でも読めなかった。
  - **対象外**：買う販路ではない。
- `{語}` は検索語（URLエンコードする）。「Shift_JISの語」とあるサイトは、検索語を Shift_JIS でエンコードする。
- ボット確認やCAPTCHAが出たら、解かず、回避もしない。
- 価格.comやモール支店で見た値は、その店のページを見たことにならない（「未確認」として扱う）。

## 見えないときの見分け方

| 見え方 | よくある原因 | 試すこと |
|---|---|---|
| curl・ヘッドレスで 403、Access Denied、HTTP/2 エラー、空のページ | 自動アクセスへの制限（Akamai・Cloudflare など） | 通常のブラウザで開く。11/20 は量販店・リユース店の多くがこれで開いた |
| 通常のブラウザでも Access Denied、ボット確認で止まる | 強い制限 | そのサイトは「見られない」と書く。モール支店や価格.comで候補だけ拾い、値は未確認として扱う |
| 「メンテナンス」「停止中」のページ | サイト側の停止 | 日を改めて開き直す。モール支店があればそちらを見る |
| 検索結果が文字化けする、または0件や無関係な結果になる | 検索語の文字コードの違い | Shift_JIS でエンコードし直す |
| 件数が不自然に多い | パラメータの名前の間違い | 名前を直す（例：トレジャーファクトリーの `word=`） |
| 「該当なし」の表示、0件ページ（サイトによっては404） | 本当の0件 | 別の型番・日本語名で探し、それでも無ければ0件と書く |

## 価格比較（候補探し用）

- **価格.com**（curl可）　検索：`kakaku.com/search_results/{cp932でエンコードした語}/`
  - ＊文字コードが cp932 なので、検索語も cp932 でエンコードし、HTMLも cp932 で読むとうまくいく。
  - ＊`/item/{K}/shop/` のショップ一覧で、各店の価格・送料・在庫・ポイントを拾える。「売り場へ行く」ボタンの onclick にある `k3c.atrack.ping({shpname, shpbid, shpshp, shppnt})` が確実。同じ店がタブ違いで重複して出るので除く。
  - ＊大きい画像は `img1.kakaku.k-img.com/images/productimage/fullscale/{K}.jpg`（`kakaku.com/images/…` は404）。
- **Googleショッピング**（通常のブラウザ要）　検索：`google.com/search?udm=28&q={語}`
  - ＊ヘッドレスではボット確認（/sorry/）が出たが、通常のブラウザでは一覧と価格が見られた。
- **Keepa**（条件付き）
  - ＊ページ本体は、通常のブラウザでも「Anti-bot check」で止まった。
  - ＊ASIN が分かれば、`graph.keepa.com/pricehistory.png?asin={ASIN}&domain=co.jp&amazon=1&new=1&used=1` を curl で取ると、新品・中古の価格の推移を画像で見られる。

## 大手モール

- **Amazon.co.jp**（ブラウザ要）　検索：`amazon.co.jp/s?k={語}&s=price-asc-rank`
  - ＊検索は curl だと503になるので、ブラウザで開くとうまくいく。
  - ＊個別 `/dp/{ASIN}` は、次の場所から読める。
    - 価格：`#corePriceDisplay`
    - 在庫：`#availability`
    - 販売者：`#merchantInfoFeature_feature_div`
    - 送料：配送ブロック
    - 大きい画像：`#landingImage` の `data-old-hires`
  - ＊出品者別・中古は `/dp/{ASIN}?aod=1` で見る（`/gp/aod/ajax` を直接開くと見つからない）。
  - ＊安い順の先頭は付属品のことが多い。状態の絞り込み（整備済み品・中古品）は、検索結果の左のリンクから取る。
- **Amazon整備済み品**（ブラウザ要）　検索：検索語に「整備済み品」を足す
  - ＊個別ページに「整備済み品 - 非常に良い」などの状態と、保証の文言が出る。
- **楽天市場**（curl可）　検索：`search.rakuten.co.jp/search/mall/{語}/?s=2`（安い順）・`&used=1`（中古）・`&sid={店ID}`（店内）
  - ＊検索結果は、`data-link="item"` の要素から商品URLが取れる。
  - ＊個別ページは EUC-JP なので変換して読む。価格と在庫は microdata の `itemprop="price|availability"`、店名は埋め込みJSONの `shopName` にある（JSON-LD に offers は無い）。
  - ＊続けて検索すると503が出るので、間隔を空ける。
  - ＊URLがASINの形（`/b0xxxxxxxx/`）の店は、無在庫転売。
- **Yahoo!ショッピング**（curl可）　検索：`shopping.yahoo.co.jp/search?p={語}&X=2`（安い順）・`&used=1`（中古）
  - ＊検索結果は、HTMLの `data-beacon`（`_cl_link:title` の方）に prc・a_prc・shipment・point・targurl・tname が入っている。
  - ＊個別ページは、JSON-LD の Product で価格・在庫を読む。送料は配送先で、ポイントはログインで変わる。
  - ＊中古では、2nd STREET の支店がまとまって出る。
- **LOHACO**（条件付き）　検索：`lohaco.yahoo.co.jp/search?p={語}&sort=%2Bprice`
  - ＊検索結果はJSで描画されるので、ブラウザで開く（`?q=` はトップに戻される）。
  - ＊個別ページは curl でも、価格・在庫・送料条件が読める。
- **au PAYマーケット**（条件付き）　検索：`wowma.jp/itemlist?keyword={語}&sort1=price,A`
  - ＊検索結果はJSで描画されるので、ブラウザで数秒待って読む。
  - ＊個別 `/item/{番号}` は curl でも、`__NEXT_DATA__` に価格・店名・在庫数・画像がある。
  - ＊中古は、商品名の「(中古品)」で見分ける。
- **Qoo10**（ブラウザ要）　検索：`qoo10.jp/gmkt.inc/Search/Default.aspx?keyword={語}`
  - ＊curl は523エラーになるので、ブラウザで開く。`/s/{語}` はランキングに飛ぶ。
  - ＊個別 `/g/{番号}` の JSON-LD に、価格（セール時の価格が入ることがある）と在庫がある。安い順はURLでは効かないので、画面で選ぶ。
- **dショッピング**（通常のブラウザ要）　検索：`dshopping.docomo.ne.jp/products_search?keyword={語}&sort=sales_price_asc`
  - ＊curl・ヘッドレスは Access Denied だが、通常のブラウザなら数秒待つと開く。
  - ＊個別 `/products/{番号}?sku=…` は、JSON-LD に価格・在庫、本文に販売店・送料・dポイント、大きい画像がある。

## 通販・メーカー公式・専門店

- **ベルメゾン**（通常のブラウザ要）　検索：検索窓から入る（`/shop/app/catalog/list/?keyword={語}`）
  - ＊curl・ヘッドレスは Akamai に拒否されるが、通常のブラウザなら開く。
  - ＊個別 `/shop/commodity/0000/{番号}` で、税込価格・ポイント・送料条件・カートが読める（JSON-LD は無い）。
- **ディノス**（curl可）　検索：`dinos.co.jp/defaultMall/sitemap/CSfSearchList_001.jsp?KEY_SEARCH={Shift_JISの語}&sort=1`
  - ＊ページも検索語も Shift_JIS。
  - ＊個別ページは、JSON-LD の `offers.priceSpecification.price` が税込価格。送料は本文にある。
- **ジャパネットたかた**（curl可）　検索：`japanet.co.jp/shopping/swd/{語}/`
  - ＊個別ページは、JSON-LD の `offers.Price`（大文字の P）が価格で、大きい画像は `-l.jpg`。送料は本文の「お支払総額（送料○円）」。ページは cp932。
- **QVCジャパン**（通常のブラウザ要）　検索：`qvc.jp/catalog/search.html?keyword={語}`
  - ＊curl・ヘッドレスは Akamai の通信エラー（curl は418）だが、通常のブラウザなら開く。
  - ＊個別 `/product.{番号}.html` の JSON-LD に、価格と在庫がある。
- **ショップチャンネル**（curl可）　検索：`shopch.jp/pc/product/prodlist/keyword?keyWord={語}&sort=2`
  - ＊個別ページは、本文の「¥○○（税込）」が価格で、画像は og:image（`L.jpg` が大きい）。在庫と送料の額はHTMLから読めなかった。
- **パナソニック Store Plus**（通常のブラウザ要）　購入ページ：`panasonic.jp/{分類}/products/{型番}/shopping.html`
  - ＊製品ページの「公式通販サイトで購入」から入る。色別のページ（`shopping.{型番-色}.html`）に、税込価格・在庫状況・お届け目安・購入ボタンが出る。
  - ＊`ec-plus.panasonic.jp` は、curl・ヘッドレスでは応答しない。製品ページの JSON-LD にある価格は参考値。
- **BALMUDA公式**（curl可）　購入ページ：`store.balmuda.com/disp/CBlSfSelectGoodsPage.jsp?PRODUCT_SERIES={型番}`
  - ＊価格と在庫は、store 側の本文に色別で出る（「完売しました」など）。送料は3,300円以上で無料（11/20時点）。
- **cado公式**（curl可）　検索：`cado.com/search?q={語}`
  - ＊在庫は、本文の「売り切れ」の文字ではなく JSON-LD の `offers.availability` で判断する（在庫ありの商品にも、その文字が埋め込まれている）。
- **アイリスプラザ**（停止中）
  - ＊11/20時点で、不正アクセスの件によりECサイトが一時停止していた（503）。
  - ＊Yahoo!ショッピングの公式店（`store.shopping.yahoo.co.jp/irisplaza/`）で探せるが、値はその店のもの。
- **ダイソン公式**（通常のブラウザ要）
  - ＊curl・ヘッドレスは Cloudflare のブロックだが、通常のブラウザなら開く。
  - ＊製品ページの JSON-LD に、価格・在庫がある。
- **plywood**（curl可）　検索：`www.plywood.jp/shop/shopbrand.html?search={語}&sort=price`
  - ＊ページは EUC-JP。価格は本文と、メタタグ `product:price:amount` にある。
- **コストコ**（条件付き）　検索：`costco.co.jp/search?text={語}&sort=price-asc`
  - ＊検索結果はJSで描画されるので、ブラウザで開く。会員でなくても多くの商品は価格が見える（一部は「ログインして価格を表示」）。
  - ＊個別ページは curl でも、JSON-LD に税込価格がある。「2個セット」などは、1個あたりの価格で比べる。

## 家電量販

- **ヨドバシ.com**（通常のブラウザ要）　検索：`yodobashi.com/?word={語}&sorttyp=SELL_PRICE_ASC&discontinued=false`
  - ＊curl・ヘッドレスは HTTP/2 エラーで開かないが、通常のブラウザなら開く。
  - ＊個別 `/product/{番号}/` で、価格・ポイント・配達料・在庫・カートが読める。画像は og:image にある。
- **ビックカメラ.com**（通常のブラウザ要）　検索：`biccamera.com/bc/category/?q={Shift_JISの語}&sort=02`
  - ＊ヘッドレスでは開かない。検索語は Shift_JIS でエンコードする（UTF-8 だと文字化けして、別の結果になる）。
  - ＊個別 `/bc/item/{番号}/` で、価格・10%ポイント・送料・在庫・カートが読める。画像は `image.biccamera.com/img/{番号}_A01.jpg`（`?sr.` 以降を外すと大きい）。
- **ジョーシンweb**（不可）
  - ＊curl・ヘッドレス・通常のブラウザのどれも、Akamai の Access Denied だった。
  - ＊楽天の「Joshin web」店（`rakuten.co.jp/jism/`、店内検索は `&sid=206032`）なら、curl で個別ページの価格・在庫が読める。値は楽天店のもの。
- **コジマネット**（ブラウザ要）　検索：`kojima.net/ec/prod_list.html?keyword={語}&sort=4`
  - ＊curl は202で空になる。ヘッドレスでも、数秒待てば読める。価格・在庫・送料は本文にある。
  - ＊画像URLの `IMG_PATH_M` を `IMG_PATH_L` に変えると、大きい画像になる。
- **ヤマダウェブコム**（通常のブラウザ要）　検索：トップの検索窓から入る（`/search/{語}/?category=all&searchbox=1`）
  - ＊ヘッドレスは HTTP/2 エラーになる。通常のブラウザでも、`/search/{語}/` を直接開くと「アクセスが制限されました」になったが、検索窓から入ると検索できた。
  - ＊個別 `/{番号}/` で、価格・お届け日・カートが読める。送料の額は「配送料金について」のページにある。
- **ケーズデンキ**（通常のブラウザ要）　検索：`ksdenki.com/search?keyword={語}&sort=4`
  - ＊個別 `/item?sku={JAN}` の JSON-LD に、価格・在庫がある。送料は本文に出る。
- **ノジマオンライン**（通常のブラウザ要）　検索：`online.nojima.co.jp/app/catalog/list/init?searchWord={語}`
  - ＊ヘッドレスは Akamai の403だが、通常のブラウザで数秒待つと開く。
  - ＊個別 `/commodity/1/{JAN}/` で、税込価格・ポイント・送料・カートが読める。画像は JSON-LD にある。
- **エディオン**（停止中）
  - ＊11/20時点で全機能がメンテナンス中だった（再開予定 11/21 10:00）。
  - ＊楽天のエディオン店（`&sid=272415`）は、curl で個別ページの価格・送料・在庫が読める。取り寄せ品は、OutOfStock でもボタンが有効なことがある。
- **ソフマップ**（条件付き）　検索：`sofmap.com/search_result.aspx?keyword={語}&product_type=USED&order_by=PRICE_ASC&stk_flg=2`
  - ＊検索結果はJSで描画されるので、ブラウザで読む。
  - ＊個別 `product_detail.aspx?sku=…` は curl でも読める。新品は JSON-LD に価格・在庫がある（中古は本文を読む）。HTMLは Shift_JIS。
  - ＊画像は og:image ではなく `image.sofmap.com/images/product/…` から取る。
- **ベスト電器**（対象外）
  - ＊自社の通販は無い。通販は Yahoo!ショッピングの店だけ。
- **ドン・キホーテ**（停止中）
  - ＊11/20時点で、公式通販 shop.donki.com はメンテナンスページに転送された。

## インテリア・雑貨

- **ニトリネット**（通常のブラウザ要）　検索：`nitori-net.jp/ec/search/?q={語}&sort=price-asc`
  - ＊curl・ヘッドレスは HTTP/2 エラーだが、通常のブラウザなら開く。
  - ＊個別 `/ec/product/{番号}/` で、価格・送料・カート・画像が読める。
- **IKEA**（条件付き）　検索：`ikea.com/jp/ja/search/?q={語}&sort=PRICE_LOW_TO_HIGH`
  - ＊検索結果はブラウザで描画される。個別ページは curl でも、JSON-LD に価格・在庫・画像がある。
  - ＊送料と店舗の在庫は、郵便番号を入れないと出ない。
- **無印良品ネットストア**（停止中）
  - ＊11/20時点で、ネットストアの全サービスが停止していた（セキュリティ強化のため）。
- **ロフト**（curl可）　検索：`loft.co.jp/store/goods/search.aspx?search=x&keyword={語}&sort=price`
  - ＊個別ページの JSON-LD に、価格・在庫がある。送料はご利用ガイドにある。
- **ハンズ**（curl可）　検索：`hands.net/search/?q={語}&rankBy=price(float)/jpy:ascending`
  - ＊JSON-LD は無いので、本文の価格・在庫を読む。価格が2つ出る商品は、どちらが今の価格かを確かめる。
- **Francfranc**（curl可）　検索：`francfranc.com/search?q={語}`
  - ＊Shopify。個別ページの JSON-LD に、価格・在庫・画像がある（`width=2000` で大きい）。安い順の指定は効かなかった。
- **ACTUS**（条件付き）　検索：`online.actus-interior.com/search/?q={語}&sortKey=price_asc`
  - ＊`www.actus-interior.com` は企業サイトで、通販は `online.` の方。
  - ＊検索結果はブラウザで読む。個別 `/item/{ID}/` は curl でも JSON-LD が読める。
- **unico**（条件付き）　検索：`unico-fan.co.jp/search?q={語}&sort_by=price-ascending`
  - ＊ページが4〜5MBと重い。送料は注文画面まで出ない。予約販売の商品は「在庫あり」でも、発送日が決まっていないことがある。
- **IDÉE**（条件付き）　検索：`idee-online.com/shop/goods/search.aspx?search=x&keyword={Shift_JISの語}`
  - ＊Shift_JIS なので、UTF-8 の検索語では0件になる。JSON-LD は無いので、本文を読む。
- **北欧、暮らしの道具店**（通常のブラウザ要）　個別：`/product_contents/{番号}`（一覧からたどる）
  - ＊curl・ヘッドレスは CloudFront の403だが、通常のブラウザなら開く。
  - ＊個別ページで、税込価格・カート・画像（imgix）が読める。

## ホームセンター・法人通販

- **カインズ**（curl可）　検索：`cainz.com/search/?q={語}&sortRule=lowPrice`
  - ＊個別 `/g/{JAN}.html` の JSON-LD に、価格・在庫がある。在庫と最大注文数は、受け取る店舗で変わる。
- **コーナン**（curl可）　検索：`kohnan-eshop.com/shop/goods/search.aspx?keyword={語}&search=x&seq=gp`
  - ＊安い順は `seq=gp`（`sort=price` は効かない）。「店舗受取のみ」「メーカー直送」の注意書きを読む。
- **DCM**（停止中）
  - ＊11/20時点で全面休止していた（再開日は未定）。
- **ビバホーム**（条件付き）　検索：`vivahome.com/search/?q={語}&srule=price-low-to-high`
  - ＊通販は「ビバムサシオンライン」。JSON-LD の価格は税抜なので、税込は本文の「Web販売価格」を使う。
  - ＊curl で取ったHTMLには「売り切れ」の文言が隠れて入っているので、在庫は画面で見る。
- **モノタロウ**（通常のブラウザ要）　検索：`monotaro.com/s/?q={語}`
  - ＊curl・ヘッドレスは Akamai の Access Denied だが、通常のブラウザなら開く。
  - ＊個別 `/g/{番号}/` で、税込価格・出荷目安・「バスケットに入れる」・大きい画像（`/pi/full/`）が読める。
- **ASKUL**（ブラウザ要）　検索：`askul.co.jp/ksearch/?searchWord={語}&sortDir=1`
  - ＊curl は403だが、ヘッドレスなら読める。ログインなしで税込価格と在庫が見える。個人が買えるかは確かめていない。
- **たのめーる**（curl可）　検索：`tanomail.com/search/res/{語}/`
  - ＊ログインなしで、税込価格・在庫・ポイントが見える。画像URLの `?sr.dw=` を外すと原寸になる。
- **カウネット**（curl可）　検索：`kaunet.com/rakuraku/spook3/main?ShowList=1&Keyword={Shift_JISの語}&SortOrder=Ascending`
  - ＊取扱いが終わった商品は、JSON-LD の在庫が画面と食い違う。本文の表示で判断する。
- **Amazonビジネス**（対象外）
  - ＊ログインしないと価格が出ない。

## フリマ・オークション・個人間

- **メルカリ**（ブラウザ要）　検索：`jp.mercari.com/search?keyword={語}&status=on_sale&sort=price&order=asc`（売却済みの相場は `status=sold_out`）
  - ＊JSで描画されるので、curl では価格が取れない。ブラウザで開くと、描画後の JSON-LD に価格・在庫が入る。
- **メルカリShops**（ブラウザ要）　メルカリの検索結果に混ざって出る
  - ＊個別 `/shops/product/{id}` もJSで描画される。送料は購入者負担で、「¥480~3,000」のように幅でしか出ない。
- **ラクマ**（curl可）　検索：`fril.jp/s?query={語}&transaction=selling&sort=sell_price&order=asc`
  - ＊個別は `item.fril.jp/{id}`。売り切れても JSON-LD は `InStock` のままなので、本文の「SOLD OUT」と「購入に進む」の有無で判断する。
- **PayPayフリマ**（curl可）　検索：`paypayfleamarket.yahoo.co.jp/search/{語}?open=1&sort=price&order=asc`
  - ＊検索結果の商品は、HTMLの `<a href="/item/z…">` にある（`__NEXT_DATA__` ではない）。個別ページは、JSON-LD で価格・在庫・送料が読める。
  - ＊英字の型番で探すと無関係の商品が混ざるので、商品名で見分ける。
- **ヤフオク**（curl可）　検索：`auctions.yahoo.co.jp/search/search?p={語}&s1=cbids&o1=a`、落札相場：`/closedsearch/closedsearch?p={語}`
  - ＊`__NEXT_DATA__` に、現在価格・入札数・即決価格・終了日時がある。
  - ＊荷物のサイズを決めていない出品は、送料が「落札者負担」とだけ出て、額が分からない。
- **モバオク**（curl可）　検索：`mbok.jp/_l?q={Shift_JISの語}&o=1`
  - ＊ページも検索語も Shift_JIS。型番で探すと0件になりやすい。
- **オークファン**（ブラウザ要）　検索：`aucfan.com/search1/q-{語}/`
  - ＊ログインなしで、直近30日・9ページまでの落札相場が見られる。JSで描画される。
- **ジモティー**（curl可）　検索：`jmty.jp/all/sale/search?keyword={語}`（都道府県で絞るなら `/{pref}/sale/search`）
  - ＊`sale-all?keyword=` ではキーワードが効かない。
  - ＊「受付終了投稿一覧」の見出しより後ろは受付終了なので除く。問い合わせにはログインが要る。
- **Facebook Marketplace**（対象外）
  - ＊ログインしないと場所が米国に固定され、日本の出品が出ない。
- **おいくら**（対象外）
  - ＊買取の一括査定サイトで、買うことはできない。売るときの相場の参考にはなる。

## リユース店

- **2nd STREET**（通常のブラウザ要）　検索：`2ndstreet.jp/search?keyword={語}&sortBy=price&sortOrder=asc`
  - ＊curl・ヘッドレスは Akamai の Access Denied だが、通常のブラウザなら開く。
  - ＊個別 `/goods/detail/goodsId/{13桁}/shopsId/{店}` は、JSON-LD に品番・画像・状態がある。本文には状態ランク・店舗・送料（11/20時点で1注文770円）が出る。
- **2nd STREET の楽天店・Yahoo!店**（curl可）
  - 楽天：`item.rakuten.co.jp/jumblestore/{13桁}/`
  - Yahoo!：`store.shopping.yahoo.co.jp/ssol-shopping/{13桁}.html`
  - ＊同じ13桁の商品番号で、同じ在庫を引ける（価格・送料も一致した）。自社ECも同じ番号の体系。
- **ハードオフ（オフモール）**（curl可）　検索：`netmall.hardoff.co.jp/search/?q={語}&s=3`
  - ＊0件のときは HTTP 404 が返る。`/cate/?keyword=` は使えない。
  - ＊個別ページの JSON-LD の価格は税抜。税込価格とランクは本文にある。
  - ＊送料は `POST /ajax/CHfOmCalcDelvCom_J.jsp`（`toPref`＝都道府県名、`goodsNo`）で、都道府県ごとに取れる。
- **トレジャーファクトリー**（curl可）　検索：`ec.treasure-f.com/search?word={語}&order=lowprice&step=1`
  - ＊`keyword=` だと全件が出る。0件でも200が返る。
  - ＊送料は `/item/postage?code={商品番号}&prefId={都道府県コード}` で取れる。画像URLの `/450/` を `/1500/` にすると大きい。
- **ブックオフ オンライン**（curl可）　検索：`shopping.bookoff.co.jp/search/keyword/{語}?sort=50`
  - ＊家電は扱っていない。在庫なしの商品も混ざるので、「在庫あり」の表示を見る。
- **ゲオオンラインストア**（通常のブラウザ要）　検索：`ec.geo-online.co.jp/shop/goods/search.aspx?search=x&keyword={Shift_JISの語}&sort=sp`
  - ＊curl・ヘッドレスは Akamai に拒否されるが、通常のブラウザなら開く。検索語は Shift_JIS（UTF-8 だと文字化けする）。
  - ＊個別 `/shop/g/g{番号}/` で、状態ランク・税込価格・送料の条件・保証・カートが読める。
- **KOMEHYO**（通常のブラウザ要）　検索：`komehyo.jp/search/?q={語}`
  - ＊curl・ヘッドレスはエラーページに飛ばされるが、通常のブラウザなら開く。
  - ＊個別 `/product/{番号}/` で、税込価格・商品ランク・在庫店舗・付属品・カートが読める。
- **買取王国**（curl可）　検索：`okoku.jp/search?q={語}&sort_by=price-ascending&filter.v.availability=1`
  - ＊Shopify。個別ページの JSON-LD に、価格・在庫がある。
- **ワンダーレックス**（curl可）　検索：`wonderrex-online.com/search?q={語}&sort_by=price-ascending`
  - ＊`wonderrex.jp` は会社のサイト。送料表は `/policies/shipping-policy` にある。売り切れの商品も混ざる。
- **リサイクルマート**（対象外）
  - ＊店頭だけで、ネット販売は無い。

## 海外・レンタル

- **eBay**（通常のブラウザ要）　検索：`ebay.com/sch/i.html?_nkw={語}&_sop=15`
  - ＊curl は403、ヘッドレスはエラーだが、通常のブラウザなら開く。
  - ＊個別 `/itm/{番号}` で、円に換算した価格・送料の欄・カートが読める。画像は `s-l400` を `s-l1600` にすると大きい。関税や通関の注意書きも読む。
- **Amazon.com**（条件付き）
  - ＊検索は amazon.co.jp に転送される。`/dp/{ASIN}` を開くと、日本へ配送できるかが出る（確かめた4商品はすべて配送不可で、送料と関税は確かめられていない）。
- **AliExpress**（ブラウザ要）　検索：`ja.aliexpress.com/w/wholesale-{語}.html`
  - ＊curl は確認ページに飛ばされる。ブラウザなら、個別ページの JSON-LD（`offers.price`）と本文の送料が読める。店名は取れなかった。
- **BUYMA**（curl可）　検索：`buyma.com/r/-O3/{語}/`（安い順）
  - ＊個別ページの JSON-LD（`hasVariant[].offers`）に、価格・在庫・色別がある。
  - ＊送料は、JSON-LD が0円でも本文が「送料着払」のことがあるので、本文を見る。
- **Rentio**（curl可）　検索：`rentio.jp/products?keywords={語}&sorting=ascend_by_master_price`
  - ＊JSON-LD の `lowPrice` は最安の月額。ワンタイムの料金と配送手数料は本文に、在庫はお届け日のカレンダーにある。
- **CLAS**（条件付き）　検索：`clas.style/search?q={語}`
  - ＊検索結果はブラウザで描画される。個別 `/{番号}` は curl でも、月額・在庫・配送できるかが読める。

## 価格以外の情報源

- **消費者庁リコール情報サイト**（curl可）　検索：`recall.caa.go.jp/result/index.php` に POST（`search={語}&screenkbn=01&category=0`）
  - ＊詳細 `detail.php?rcl={番号}` の型番・販売期間・対応は、`<script>` 内の `contentsText` の JSON に入っている。
- **CPSC**（curl可）　API：`saferproducts.gov/RestWebServices/Recall?format=json&ProductName={語}`
  - ＊サイトの検索は curl では絞り込まれないので、公式APIを使うとうまくいく。
- **仕様・取扱説明書・互換**
  - 仕様は公式の仕様表で確かめる。取扱説明書の PDF は `pdftotext` で全文検索する。画像だけのPDFは、高い解像度で画像にして目で読む。付属品の互換は公式FAQで確かめる。

## 品目別の専門店

- **マップカメラ**（通常のブラウザ要）　検索：`mapcamera.com/search?keyword={語}`
  - ＊curl・ヘッドレスは Akamai の403だが、通常のブラウザなら開く。
  - ＊個別 `/item/{番号}` で、税込価格・付属品・カートが読める。価格は JSON-LD にもある。画像は `…/1/l.jpg`。
- **カメラのキタムラ**（ブラウザ要）　検索：`shop.kitamura.jp/ec/list?keyword={語}&sort=price`、中古の一覧：`?keyword3={JAN}&type=u`
  - ＊SPA なので、curl では空になる。ブラウザで2〜3秒待つと、中古 `/ec/used/{管理コード}` の状態ランク・付属品・保証まで読める。
- **じゃんぱら**（通常のブラウザ要）　検索：`janpara.co.jp/sale/search/result/?KEYWORDS={語}`
  - ＊curl・ヘッドレスは WAF に拒否されるが、通常のブラウザなら開く。
  - ＊詳細 `/sale/search/detail/?ITMCODE={番号}` に、在庫のある店舗ごとの価格と状態が並ぶ。og:image は分類の画像なので、商品の画像は本文から取る。
- **イオシス**（curl可）　検索：`iosys.co.jp/items?q={語}&sort=l`
  - ＊JSON-LD に、価格・在庫・状態がある。検索語の一致が緩いので、型番まで入れる。送料の表示は無い。
- **イシバシ楽器**（curl可）　検索：`store.ishibashi.co.jp/search?q={語}&sort=price`（中古だけなら `&s4[0]=中古`）
  - ＊JSON-LD に価格・在庫がある。中古はランクと付属品が読める。売れた後も掲載が残ることがある。
- **デジマート**（通常のブラウザ要）　検索：`digimart.net/search?keywordAnd={語}`
  - ＊curl・ヘッドレスは Cloudflare の確認画面だが、通常のブラウザなら開く。
  - ＊個別 `/cat01/shop{n}/DS{n}/` で、税込価格・送料・状態・出品店が読める。
- **ベビーザらス**（通常のブラウザ要）　検索：`toysrus.co.jp/ja-jp/search/?q={語}`（`babiesrus.co.jp` に転送される）
  - ＊curl・ヘッドレスはボット確認で止まった。通常のブラウザでは、操作しなくても自動で通過して開いた。
  - ＊個別 `/ja-jp/{番号}.html` の JSON-LD に、価格・在庫がある。
- **赤ちゃん本舗**（curl可）　検索：`shop.akachan.jp/shop/goods/search.aspx?search=x&keyword={語}&sort=sp`
  - ＊`www.akachan.jp` は価格のないカタログ。通販の個別ページは、JSON-LD に価格・在庫がある。
- **ZOZOTOWN**（通常のブラウザ要）　検索：`zozo.jp/search/?p_keyv={Shift_JISの語}`
  - ＊curl・ヘッドレスは応答しないが、通常のブラウザなら開く。検索語は Shift_JIS（UTF-8 だと文字化けして0件になる）。
  - ＊個別 `/shop/{店}/goods/{番号}/` で、サイズ別の在庫・税込価格・カートが読める。JSON-LD の在庫は、サイズ別の表示と食い違うことがある。
- **ロコンド**（条件付き）　検索：`locondo.jp/shop/search?keyword={語}&alignmentSequence=price%20asc`
  - ＊検索結果はJSで描画される（curl だと0件になる）。個別ページは curl でも、JSON-LD の価格とサイズ別の在庫が読める。
- **楽天ブックス**（条件付き）　検索：`books.rakuten.co.jp/search?sitem={語}&s=4`
  - ＊検索は curl で取れる。個別 `/rb/{番号}/` は curl だと「見つかりません」が返るので、ブラウザで開く。
- **honto**（条件付き）　検索：`honto.jp/netstore/search.html?k={語}`
  - ＊電子書籍だけを扱う。紙の本は、連携書店の外部サイトに送られる。
- **紀伊國屋書店ウェブストア**（条件付き）　検索：トップの検索窓から入る（POST）
  - ＊個別 `/f/dsg-01-{ISBN}` は curl でも、価格・在庫冊数・ポイント・大きい表紙画像が読める。
  - ＊検索はURLに語が残らないので、ブラウザで検索窓から入る。安い順の並べ替えは無い。

**専門店の足し方**

- メーカーの「取扱店一覧」「正規販売店」のページを見る。
- 「{品名} 取扱店」「{品名} 中古 専門店」「{型番} 在庫」でWeb検索し、上位に出た店のうち、ここに無いものを全部足す。
- 価格.comのショップ一覧に出てくる、知らない店も足す。
- リユース店では、品目のカテゴリーページも見る（検索に出ない在庫がある）。

## 一覧から外したもの

- インテリアズー、ルカリカ、エコリン村、ドンドンダウン：いまの通販のURLを特定できなかった（ルカリカのドメインは売りに出ている）。
