## Keşif Talimatları

Robotunuzu izleyin ve ilgili düğmelere tıklayarak eylemlerini kaydedin. Eylemler için kullanılan simgeler şunlardır:

| | Topla | Kaldır<br>(toplamadan) | Bırak<br>veya Kaçır | Yerleştir<br>veya Puanla | Ayrıl | Tırman |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Mercan** | <img src=coral-collect.png style=height:5em> | | <img src=coral-drop.png style=height:5em> | <img src=coral-place.png style=height:5em> | | |
| **Yosun** | <img src=algae-collect.png style=height:5em> | <img src=algae-remove.png style=height:5em> | <img src=algae-drop.png style=height:5em> | <img src=algae-place.png style=height:5em> | | |
| **Robot** | | | | | <img src=leave.png style=height:5em> | <img src=climb.png style=height:5em> |

Botunuz işlemciye yosun yerleştirdikten sonra, **rakibin insan oyuncusu** o yosunu kendi mavna ağına atarsa ​​bunu kaydetmekten siz sorumlusunuz.

Sahadaki görüntüdeki çoğu düğme, bu eylemin gerçekleştiği yere yerleştirilir, ancak istisnalar vardır:

- Bırakma düğmesi (<img src=coral-drop.png style=height:1em> ve <img src=algae-drop.png style=height:1em>) **sahanın kenarında** görünür, ancak bir oyun parçası **herhangi bir yere bırakıldığında** kullanılmak üzere tasarlanmıştır.
- Otomatik modda, başlangıç ​​çizgisinden ayrılma (<img src=leave.png style=height:1em>) robot herhangi bir konumdan başlangıç ​​çizgisinden ayrıldığında basılmalıdır.
- Telop modunda, toplama düğmeleri (<img src=coral-collect.png style=height:1em> ve <img src=algae-collect.png style=height:1em>) **halıda**, konumdan bağımsız olarak **herhangi bir yerden alma** için kullanılmak üzere tasarlanmıştır. - Telop'ta, toplama düğmeleri (<img src=coral-collect.png style=height:1em> ve <img src=algae-collect.png style=height:1em>) **sahanın diğer tarafında** **sahanın diğer tarafındaki** herhangi bir toplama için, yerden veya başka bir yerden, kullanılmak üzere tasarlanmıştır.

Tırmanma düğmesi (<img src=climb.png style=height:1em>), tırmanma süresine sürekli olarak saniyeler ekleyecek bir zamanlayıcı başlatır. Robot yerden başarıyla kalktığında, pes ettiğinde veya maç sona erdiğinde düğmeye ikinci kez basın.

### Maç Yapısı
Her maçın keşfi dört döneme ayrılır:
- **Maç öncesi** — Maç başlamadan önce.
- **Otonom** — Robot, insan oyunculardan girdi almadan bağımsız olarak hareket eder.
- **Uzaktan kumandalı** — Robot uzaktan kumanda ile kontrol edilir. - **Oyun sonu** — Robot kafeslere tırmanmaya veya mavnanın altına park etmeye çalışır.

Otomatik sona erdiğinde teleop'a ​​geçtiğinizden emin olun. Teleop'a ​​geçmeyi unutmak yaygın bir keşif hatasıdır. Teleop'a ​​devam etme düğmesi size hatırlatmak için <span style=color:red>kırmızı</span> ve <span style=color:blue>mavi</span> yanıp sönmeye başlayacaktır.

### Verilerinizi Kaydetme

İşiniz bittiğinde verileri kaydetmek için alttaki düğmelerden birini kullanın. Önerilen düğme büyütülecektir — genellikle bu, bir sonraki maça geçmek için kullanılacak düğme olacaktır, ancak belirli durumlarda uygulama verilerinizi keşif merkezine yüklemenizi önerecektir. Kablosuz bir ağ değilseniz, verilerinizi yüklemek için cihazınızı merkeze takmanız gerekecektir.
