-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Anamakine: 127.0.0.1:3306
-- Üretim Zamanı: 05 May 2023, 14:41:28
-- Sunucu sürümü: 8.0.31
-- PHP Sürümü: 8.0.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `2021469023`
--

DELIMITER $$
--
-- Yordamlar
--
DROP PROCEDURE IF EXISTS `akd firmasi urunleri`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `akd firmasi urunleri` ()   SELECT urun.Urun_Adi,urun.Fiyati FROM urun,firmalar 
WHERE urun.Firma_ID=firmalar.Firma_ID AND firmalar.Firma_Adi LIKE 'akd%'$$

DROP PROCEDURE IF EXISTS `any`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `any` ()   SELECT urun.Urun_Adi,urun.Tarih,urun.Fiyati,urun.Satis_Miktari
FROM urun 
WHERE urun.Satis_Miktari>ANY(SELECT urun.Satis_Miktari FROM urun,firmalar WHERE firmalar.Firma_ID=urun.Firma_ID AND
                      firmalar.Firma_Adi='erft')$$

DROP PROCEDURE IF EXISTS `between_not_in`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `between_not_in` (IN `min_tutar` INT(50), IN `max_tutar` INT(50))   SELECT * 
FROM urun WHERE fiyati BETWEEN min_tutar and max_tutar 
AND urun.Urun_Adi NOT IN('kalem')$$

DROP PROCEDURE IF EXISTS `istenilen sayidan fazla musterisi olan urunler`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `istenilen sayidan fazla musterisi olan urunler` (IN `sayi` INT(12))   SELECT urun.Urun_Adi,urun_musteri.Urun_ID,COUNT(urun_musteri.Musteri_ID) 
AS musteri_sayisi FROM
urun,urun_musteri WHERE urun_musteri.Urun_ID=urun.Urun_ID
GROUP BY urun_musteri.urun_ID
HAVING musteri_sayisi>sayi$$

DROP PROCEDURE IF EXISTS `kdv orani guncelleme`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `kdv orani guncelleme` (IN `yeni_kdv_orani` INT(10))   UPDATE kategoriler SET kdv_orani=yeni_kdv_orani 
WHERE kategoriler.Kategori_ID=kategoriler.Kategori_ID$$

DROP PROCEDURE IF EXISTS `musteri tablosuna veri ekleme`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `musteri tablosuna veri ekleme` (IN `ad` VARCHAR(50) CHARSET utf8mb3, IN `adres` VARCHAR(50) CHARSET utf8mb3, IN `ID` INT(50), IN `soyad` VARCHAR(50) CHARSET utf8mb3, IN `telefon` INT(50))   INSERT INTO musteriler(ad,adres,musteri_ID,soyad,telefon) 
VALUES (ad,adres,ID,soyad,telefon)$$

DROP PROCEDURE IF EXISTS `musteriler tablosundan veri silme`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `musteriler tablosundan veri silme` (IN `ad` VARCHAR(50), IN `adres` VARCHAR(50), IN `ID` INT(50), IN `soyad` VARCHAR(50), IN `telefon` INT(50))   DELETE FROM musteriler WHERE musteriler.Ad=ad AND musteriler.Adres=adres AND
musteriler.Musteri_ID=ID AND musteriler.Soyad=soyad AND musteriler.Telefon=telefon$$

DROP PROCEDURE IF EXISTS `tum tablolari birlestirme`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `tum tablolari birlestirme` ()  CREATE VIEW tum_tablolar AS 
SELECT musteriler.Ad,musteriler.Soyad,musteriler.Telefon,
urun.Urun_Adi,urun.Fiyati,urun.Tarih,urun.Satis_Miktari,
firmalar.Firma_Adi,firmalar.Adres,kategoriler.Kategori_Adi,
kategoriler.KDV_Orani 
FROM musteriler,urun_musteri,urun,firmalar,urun_kategori,kategoriler 
WHERE musteriler.Musteri_ID=urun_musteri.Musteri_ID AND
urun_musteri.Urun_ID=urun.Urun_ID AND
urun.Firma_ID=firmalar.Firma_ID AND
urun_kategori.Urun_ID=urun.Urun_ID AND
urun_kategori.Kategori_ID=kategoriler.Kategori_ID$$

DROP PROCEDURE IF EXISTS `urun adina gore musteri sayisini bulma`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `urun adina gore musteri sayisini bulma` (IN `adi` VARCHAR(50))   SELECT urun.Urun_Adi,urun_musteri.Urun_ID,COUNT(urun_musteri.Musteri_ID) 
AS musteri_sayisi FROM
urun,urun_musteri WHERE urun_musteri.Urun_ID=urun.Urun_ID
AND urun.Urun_Adi=adi$$

DROP PROCEDURE IF EXISTS `view_yaratan`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_yaratan` ()  CREATE VIEW urunler_view AS 
SELECT urun.Urun_Adi,urun.Fiyati,firmalar.Firma_Adi
FROM urun,firmalar
WHERE urun.Firma_ID=firmalar.Firma_ID$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `firmalar`
--

DROP TABLE IF EXISTS `firmalar`;
CREATE TABLE IF NOT EXISTS `firmalar` (
  `Firma_ID` int NOT NULL,
  `Firma_Adi` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_turkish_ci NOT NULL,
  `Adres` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_turkish_ci NOT NULL,
  `Telefon` int NOT NULL,
  PRIMARY KEY (`Firma_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `firmalar`
--

INSERT INTO `firmalar` (`Firma_ID`, `Firma_Adi`, `Adres`, `Telefon`) VALUES
(1, 'akd', 'istanbul', 254885145),
(2, 'erft', 'erzurum', 535897156),
(3, 'dfg lti', 'ankara', 324578346);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `kategoriler`
--

DROP TABLE IF EXISTS `kategoriler`;
CREATE TABLE IF NOT EXISTS `kategoriler` (
  `Kategori_ID` int NOT NULL,
  `Kategori_Adi` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_turkish_ci NOT NULL,
  `KDV_Orani` int NOT NULL,
  PRIMARY KEY (`Kategori_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `kategoriler`
--

INSERT INTO `kategoriler` (`Kategori_ID`, `Kategori_Adi`, `KDV_Orani`) VALUES
(1, 'kırtasiye', 8),
(2, 'temizlik malzemesi', 8),
(3, 'plastik eşya', 8),
(4, 'içecek', 8),
(5, 'kozmetik', 8),
(6, 'yiyecek', 8),
(7, 'giyim', 8),
(8, 'takı_aksesuar', 18);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `musteriler`
--

DROP TABLE IF EXISTS `musteriler`;
CREATE TABLE IF NOT EXISTS `musteriler` (
  `Musteri_ID` int NOT NULL,
  `Ad` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_turkish_ci NOT NULL,
  `Soyad` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_turkish_ci NOT NULL,
  `Telefon` int NOT NULL,
  `Adres` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_turkish_ci NOT NULL,
  PRIMARY KEY (`Musteri_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `musteriler`
--

INSERT INTO `musteriler` (`Musteri_ID`, `Ad`, `Soyad`, `Telefon`, `Adres`) VALUES
(1, 'ömer', 'gizik', 457821568, 'erzincan'),
(2, 'esma', 'demir', 27465817, 'manisa'),
(3, 'ahmet', 'kısa', 716533781, 'izmir'),
(4, 'hasan', 'uzun', 32443523, 'izmir'),
(5, 'mehmet', 'ışık', 5646531, 'adana'),
(6, 'mustafa', 'budak', 78258742, 'kayseri'),
(7, 'lina', 'derin', 5646515, 'konya'),
(8, 'emir', 'toköz', 723547832, 'gaziantep'),
(9, 'ayşe', 'kurtulmuş', 546545312, 'bursa'),
(10, 'mert', 'kaya', 38742863, 'çorum');

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `tum_tablolar`
-- (Asıl görünüm için aşağıya bakın)
--
DROP VIEW IF EXISTS `tum_tablolar`;
CREATE TABLE IF NOT EXISTS `tum_tablolar` (
`Ad` varchar(50)
,`Soyad` varchar(50)
,`Telefon` int
,`Urun_Adi` varchar(50)
,`Fiyati` int
,`Tarih` date
,`Satis_Miktari` int
,`Firma_Adi` varchar(50)
,`Adres` varchar(50)
,`Kategori_Adi` varchar(50)
,`KDV_Orani` int
);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `urun`
--

DROP TABLE IF EXISTS `urun`;
CREATE TABLE IF NOT EXISTS `urun` (
  `Urun_ID` int NOT NULL,
  `Urun_Adi` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_turkish_ci NOT NULL,
  `Fiyati` int NOT NULL,
  `Firma_ID` int NOT NULL,
  `Tarih` date NOT NULL,
  `Satis_Miktari` int NOT NULL,
  PRIMARY KEY (`Urun_ID`),
  KEY `Firma_ID` (`Firma_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `urun`
--

INSERT INTO `urun` (`Urun_ID`, `Urun_Adi`, `Fiyati`, `Firma_ID`, `Tarih`, `Satis_Miktari`) VALUES
(1, 'kalem', 15, 3, '2023-04-02', 23),
(2, 'kitap', 45, 2, '2022-04-13', 12),
(3, 'deterjan', 79, 1, '2023-01-09', 14),
(4, 'tabak', 39, 3, '2022-12-12', 68),
(5, 'tişört', 150, 1, '2022-12-01', 47),
(6, 'krem', 89, 3, '2023-04-04', 12),
(7, 'gözlük', 400, 1, '2023-02-28', 47),
(8, 'çorap', 17, 2, '2023-06-04', 216),
(9, 'defter', 29, 2, '2022-12-27', 48),
(10, 'cüzdan', 179, 2, '2023-03-20', 15);

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `urunler_view`
-- (Asıl görünüm için aşağıya bakın)
--
DROP VIEW IF EXISTS `urunler_view`;
CREATE TABLE IF NOT EXISTS `urunler_view` (
`Urun_Adi` varchar(50)
,`Fiyati` int
,`Firma_Adi` varchar(50)
);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `urun_kategori`
--

DROP TABLE IF EXISTS `urun_kategori`;
CREATE TABLE IF NOT EXISTS `urun_kategori` (
  `Urun_ID` int NOT NULL,
  `Kategori_ID` int NOT NULL,
  KEY `Urun_ID` (`Urun_ID`),
  KEY `Kategori_ID` (`Kategori_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `urun_kategori`
--

INSERT INTO `urun_kategori` (`Urun_ID`, `Kategori_ID`) VALUES
(3, 2),
(1, 1),
(2, 1),
(4, 3),
(5, 7),
(6, 5),
(10, 8),
(9, 1),
(7, 8),
(8, 7);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `urun_musteri`
--

DROP TABLE IF EXISTS `urun_musteri`;
CREATE TABLE IF NOT EXISTS `urun_musteri` (
  `Musteri_ID` int NOT NULL,
  `Urun_ID` int NOT NULL,
  KEY `Musteri_ID` (`Musteri_ID`),
  KEY `Urun_ID` (`Urun_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_turkish_ci;

--
-- Tablo döküm verisi `urun_musteri`
--

INSERT INTO `urun_musteri` (`Musteri_ID`, `Urun_ID`) VALUES
(3, 1),
(2, 4),
(1, 2),
(2, 3),
(4, 1),
(5, 3),
(1, 5),
(3, 5),
(8, 5),
(9, 6),
(2, 6),
(4, 5),
(7, 5),
(7, 3),
(8, 1),
(10, 4),
(2, 7),
(1, 8),
(9, 1),
(8, 10);

-- --------------------------------------------------------

--
-- Görünüm yapısı `tum_tablolar`
--
DROP TABLE IF EXISTS `tum_tablolar`;

DROP VIEW IF EXISTS `tum_tablolar`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tum_tablolar`  AS SELECT `musteriler`.`Ad` AS `Ad`, `musteriler`.`Soyad` AS `Soyad`, `musteriler`.`Telefon` AS `Telefon`, `urun`.`Urun_Adi` AS `Urun_Adi`, `urun`.`Fiyati` AS `Fiyati`, `urun`.`Tarih` AS `Tarih`, `urun`.`Satis_Miktari` AS `Satis_Miktari`, `firmalar`.`Firma_Adi` AS `Firma_Adi`, `firmalar`.`Adres` AS `Adres`, `kategoriler`.`Kategori_Adi` AS `Kategori_Adi`, `kategoriler`.`KDV_Orani` AS `KDV_Orani` FROM (((((`musteriler` join `urun_musteri`) join `urun`) join `firmalar`) join `urun_kategori`) join `kategoriler`) WHERE ((`musteriler`.`Musteri_ID` = `urun_musteri`.`Musteri_ID`) AND (`urun_musteri`.`Urun_ID` = `urun`.`Urun_ID`) AND (`urun`.`Firma_ID` = `firmalar`.`Firma_ID`) AND (`urun_kategori`.`Urun_ID` = `urun`.`Urun_ID`) AND (`urun_kategori`.`Kategori_ID` = `kategoriler`.`Kategori_ID`))  ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `urunler_view`
--
DROP TABLE IF EXISTS `urunler_view`;

DROP VIEW IF EXISTS `urunler_view`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `urunler_view`  AS SELECT `urun`.`Urun_Adi` AS `Urun_Adi`, `urun`.`Fiyati` AS `Fiyati`, `firmalar`.`Firma_Adi` AS `Firma_Adi` FROM (`urun` join `firmalar`) WHERE (`urun`.`Firma_ID` = `firmalar`.`Firma_ID`)  ;

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `urun`
--
ALTER TABLE `urun`
  ADD CONSTRAINT `urun_ibfk_1` FOREIGN KEY (`Firma_ID`) REFERENCES `firmalar` (`Firma_ID`);

--
-- Tablo kısıtlamaları `urun_kategori`
--
ALTER TABLE `urun_kategori`
  ADD CONSTRAINT `urun_kategori_ibfk_1` FOREIGN KEY (`Urun_ID`) REFERENCES `urun` (`Urun_ID`),
  ADD CONSTRAINT `urun_kategori_ibfk_2` FOREIGN KEY (`Kategori_ID`) REFERENCES `kategoriler` (`Kategori_ID`);

--
-- Tablo kısıtlamaları `urun_musteri`
--
ALTER TABLE `urun_musteri`
  ADD CONSTRAINT `urun_musteri_ibfk_1` FOREIGN KEY (`Musteri_ID`) REFERENCES `musteriler` (`Musteri_ID`),
  ADD CONSTRAINT `urun_musteri_ibfk_2` FOREIGN KEY (`Urun_ID`) REFERENCES `urun` (`Urun_ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
