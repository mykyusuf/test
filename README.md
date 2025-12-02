# M3UCastPlayer

Basit bir SwiftUI iOS uygulaması. Girilen M3U/HLS bağlantısını cihaz üzerinde oynatır ve Chromecast ya da DLNA/UPnP uyumlu hedeflere yansıtmayı amaçlar.

## Özellikler
- M3U playlist dosyasını indirip parçalara ayırır, her öğeyi listede gösterir.
- Seçilen öğeyi AVPlayer ile yerelde oynatır.
- Chromecast ve DLNA hedeflerini keşfetmek için `CastManager` içindeki stub keşif mekanizmasını kullanır. Gerçek donanım için Podfile'daki bağımlılıkları yükleyip gerçek SDK'larla değiştirebilirsiniz.

## Kurulum
1. `pod install` çalıştırın ve `M3UCastPlayer.xcworkspace` dosyasını açın.
2. Uygulama hedefinde geçerli bir **Signing Team** seçin.
3. Yayın yapılacak URL'ler için `Info.plist` içindeki App Transport Security (ATS) ayarlarını gerektiği şekilde güncelleyin.

## Çalışma Zamanı
- Uygulama açıldığında verilen M3U bağlantısını alır. "Play Stream" ile ilk öğe oynatılır; listeden seçim yapılabilir.
- "Cast" butonu cihaz keşif popup'ını açar. Stub keşifleri yerine gerçek cihazları listelemek için CastManager'da ilgili SDK çağrılarını ekleyin.
