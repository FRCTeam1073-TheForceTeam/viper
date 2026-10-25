Gözlem Talimatları
========================

## Gözlem Talimatları

Robotunuzu maç boyunca izleyin ve yaptıklarını kaydedin. Bir sayacı artırmak için dokunun. Bir hata yaparsanız **Geri al** düğmesine basın. Geri al yalnızca son dokunuşunuzu geri alır; daha önceki bir hatayı düzeltmek için o noktaya kadar geri alın.

### Maçtan önce

- Takımın robotu oynamayacaksa **Gelmedi** kutusunu işaretleyin.

### Otonom (ilk 30 saniye)

Robot sürücü girişi olmadan kendi başına çalışır.

- **Duvardan ayrıldı**: otonomun sonunda robot çevre duvarına artık dokunmuyorsa işaretleyin.
- **Otonomda park etti**: otonomun sonunda robot en az kısmen kendi YÜKLEME BÖLGESİ içindeyse işaretleyin.
- **KOVAN devirme**: otonom sırasında KOVAN her devrildiğinde bir kez dokunun.
- **Toplanan**: robot her POLEN veya NEKTAR aldığında dokunun.
- **HÜCRE** ve **BAHÇE**: robot her POLEN veya NEKTAR'ı kendi ittifakınızın HÜCRE'sine veya BAHÇE'sine koyduğunda dokunun.

30 saniyelik sayaç bittiğinde **Teleop** düğmesi yanıp söner. Geçmek için basın.

### Teleop (2 dakika)

- **Toplanan**: robotun aldığı her POLEN veya NEKTAR.
- **HÜCRE**: robotun ittifakınızın yukarı bakan HÜCRE'sine fırlattığı her parça.
- **ÇİÇEK 1 ila 4**: robotun bir ÇİÇEK'in üstüne bıraktığı her parça. ÇİÇEKLERİ her maçta aynı sırayla 1'den 4'e numaralandırın ve tüm etkinlik boyunca bu sırayı koruyun.
- **BAHÇE**: robotun ittifakınızın BAHÇE'sine koyduğu her parça.
- **KOVAN devirme**: robotunuz KOVAN'a bir parça fırlattıktan sonra KOVAN her devrildiğinde.

Robotun diğer ittifakın HÜCRE'sine veya BAHÇE'sine koyduğu parçaları saymayın.

Üstteki **Tutulan** satırı, robotun şu anda taşıdığı POLEN ve NEKTAR sayısını gösterir. 4 POLEN ile başlar, çünkü her robot 4 önceden yüklenmiş parça ile başlar. Toplamak sayıyı artırır, yerleştirmek azaltır. Bir robot toplamda en fazla 4 parça tutabilir. 4 parça tuttuğunda toplama düğmeleri devre dışı kalır. Bir rengin yerleştirme düğmeleri, robot o renkten hiç tutmuyorsa devre dışı kalır. Bir sayı kırmızıya dönerse sayaçlarınızı kontrol edin: toplam 4'ten büyükse robot tutma kuralını çiğnemiş olabilir, negatif bir sayı ise bir sayacın yanlış girildiğini gösterir.

### Maç sonu

- **Park etti**: maç bittiğinde robot en az kısmen kendi YÜKLEME BÖLGESİ içindeyse işaretleyin.
- **Robot devre dışı veya sıkışmış**: robot maç sırasında çalışmayı bıraktıysa veya sıkıştıysa işaretleyin.
- **Ad** (zorunlu) ve **Yorumlar** (isteğe bağlı): faydalı olabilecek her şeyi ekleyin; örneğin bir takımın son dakikadan önce bir ÇİÇEK'e NEKTAR koyması, emin olmadığınız bir devirme veya devrilen bir robot.

Verileri ekranın alt kısmındaki düğmelerden biriyle kaydedin. Vurgulanan düğme önerilen sonraki adımdır.
