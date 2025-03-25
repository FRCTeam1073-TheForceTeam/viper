## 偵察說明

觀察您的機器人並透過點擊相應的按鈕記錄其動作。用於操作的圖示是：

| |收藏|刪除<br>（不<br>收集）|掉落<br>或錯過|名次<br>或得分 |離開 |攀爬|
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **珊瑚** | <img src=coral-collect.png style=height:5em> | | <img src=coral-drop.png style=height:5em> | <img src=coral-place.png style=height:5em> | | |
| **藻類** | <img src=algae-collect.png style=height:5em> | <img src=algae-remove.png style=height:5em> | <img src=algae-drop.png style=height:5em> | <img src=algae-place.png style=height:5em> | | |
| **機器人** | | | | | <img src=leave.png style=height:5em> | <img src=climb.png style=height:5em> |

當你的機器人將藻類放入處理器後，你負責記錄**對手的人類玩家**是否將藻類扔進他們的駁船網。

欄位影像上的大多數按鈕都放置在發生操作的位置，但也有例外：

- 放置按鈕（<img src=coral-drop.png style=height:1em> 和 <img src=algae-drop.png style=height:1em>）出現在**場地邊緣**，但每當遊戲區塊**掉落到任何地方**時就可以使用。
- 在自動模式下，當機器人從任意位置離開起始線時，應按下離開起始線 (<img src=leave.png style=height:1em>)。
- 在telop中，地毯上的收集按鈕（<img src=coral-collect.png style=height:1em> 和 <img src=algae-collect.png style=height:1em>）**用於**任何地面拾取**，無論位置如何。
- 在投影片中，收集按鈕（<img src=coral-collect.png style=height:1em> 和 <img src=algae-collect.png style=height:1em>）**位於場地的另一側**，用於**場地另一側**、地面或其他地方的任何拾取。

攀爬按鈕 (<img src=climb.png style=height:1em>) 會啟動一個計時器，該計時器會不斷增加攀爬時間。當機器人成功離地、放棄或比賽結束時，再次按下按鈕。

### 匹配結構
每場比賽的球探分為四個階段：
 - **賽前** — 比賽開始前。
 - **自主** - 機器人獨立行動，無需人類玩家的輸入。
 - **遙控** — 機器人透過遠端控制進行控制。
 - **遊戲結束** — 機器人嘗試爬上籠子或停在駁船下方。

當自動結束時，請務必切換到遠端操作。忘記轉向遠端操作是一個常見的偵察錯誤。遠端操作的按鈕將開始閃爍<span style=color:red>紅色</span>和<span style=color:blue>藍色</span>提醒您。

### 儲存您的數據

完成後，使用底部的按鈕之一儲存資料。建議的按鈕將被放大 - 通常這將是進入下一場比賽的按鈕，但在某些情況下，應用程式會建議您將資料上傳到球探中心。如果您不是無線網絡，則需要將裝置插入集線器才能上傳資料。
