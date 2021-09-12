
#Область ПрограммныйИнтерфейс

// Раскодирует строку в кодировке application/x-www-form-urlencoded
// В отличие от РаскодироватьСтроку предварительно преобразует плюсы в пробелы
// Подходит для раскодирования строк полученных из post-данных html-форм
//
// Параметры:
//  Строка - Строка - Строка, закодированная в application/x-www-form-urlencoded
// 
// Возвращаемое значение:
//  Строка - Раскодированная строка
//
Функция Раскодировать(Знач Строка, Знач Кодировка = Неопределено) Экспорт
	
	Если ТипЗнч(Строка) <> Тип("Строка") Тогда
		Возврат Строка;
	КонецЕсли;
	
	ПреобразованнаяСтрока = СтрЗаменить(Строка, "+", " ");
	
	Возврат РаскодироватьСтроку(ПреобразованнаяСтрока, СпособКодированияСтроки.URLВКодировкеURL, Кодировка);
	
КонецФункции

// Раскодирует строку в кодировке Quoted-printable
// Согласно https://en.wikipedia.org/wiki/Quoted-printable И RFC2045 пункт 6.7
//
// Параметры:
//  Строка - Строка - Строка, закодированная в Quoted-printable
// 
// Возвращаемое значение:
//  Строка - Раскодированная строка
//
Функция РаскодироватьQuotedPrintable(Знач Строка, Знач Кодировка = Неопределено) Экспорт
	
	Если Кодировка = Неопределено Тогда
		Кодировка = "utf-8";
	КонецЕсли;
	
	Значение = Строка;
	
	Результат = Новый Массив;
	Для Индекс = 1 По СтрЧислоСтрок(Значение) Цикл
		
		Строка = СтрПолучитьСтроку(Значение, Индекс);
		Если СтрЗаканчиваетсяНа(Строка, "=") Тогда
			Строка = Лев(Строка, СтрДлина(Строка) - 1);
			Результат.Добавить(Строка);
		Иначе
			Результат.Добавить(Строка + Символы.ПС);
		КонецЕсли;
		
	КонецЦикла;
	
	Строка = СтрСоединить(Результат);
	
	Результат = Новый Массив;
		
	Позиция = СтрНайти(Строка, "="); 
	Пока Позиция <> 0 Цикл
		
		HexСтрока = "";
		Результат.Добавить(Сред(Строка, 1, Позиция - 1));
		
		Строка = Сред(Строка, Позиция);
		ПолучитьОктетBase16(Строка, HexСтрока);
		
		РаскодированныеСимволы = ПолучитьСтрокуИзДвоичныхДанных(ПолучитьДвоичныеДанныеИзHexСтроки(HexСтрока), Кодировка);
		Результат.Добавить(РаскодированныеСимволы);
		
		Позиция = СтрНайти(Строка, "="); 
		
	КонецЦикла;
	
	Результат.Добавить(Строка);
	
	Возврат СтрСоединить(Результат);
	
КонецФункции

// Возвращает строку из структуры результат функции ОбщегоНазначенияКлиентСервер.СтруктураURI
//
Функция URIИзСтруктуры(Структура) Экспорт
	
	СтруктураURI = ОбщегоНазначенияКлиентСервер.СтруктураURI("");
	ЗаполнитьЗначенияСвойств(СтруктураURI, Структура);
	
	МассивURI = Новый Массив;
	
	Если ЗначениеЗаполнено(СтруктураURI.Схема) Тогда
		МассивURI.Добавить(СтруктураURI.Схема);
		МассивURI.Добавить("://");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураURI.Логин) Тогда
		МассивURI.Добавить(СтруктураURI.Логин);
		
		Если ЗначениеЗаполнено(СтруктураURI.Пароль) Тогда
			МассивURI.Добавить(":");
			МассивURI.Добавить(СтруктураURI.Пароль);
		КонецЕсли;
		
		МассивURI.Добавить("@");
	КонецЕсли;
	
	МассивURI.Добавить(СтруктураURI.ИмяСервера);
	
	Если ЗначениеЗаполнено(СтруктураURI.ПутьНаСервере) Тогда
		МассивURI.Добавить("/");
		МассивURI.Добавить(СтруктураURI.ПутьНаСервере);
	КонецЕсли;
	
	Возврат СтрСоединить(МассивURI, "");
	
КонецФункции

// Возвращает строку, содержащую MIME-тип, определенный по расширению
//
Функция MIMEТипПоРасширению(Знач Расширение) Экспорт
	
	Расширение = СтрЗаменить(Расширение, ".", "");
	
	Если Расширение = "123"				Тогда Возврат "application/vnd.lotus-1-2-3";
	ИначеЕсли Расширение = "3dml"		Тогда Возврат "text/vnd.in3d.3dml";
	ИначеЕсли Расширение = "3g2"		Тогда Возврат "video/3gpp2";
	ИначеЕсли Расширение = "3gp"		Тогда Возврат "video/3gpp";
	ИначеЕсли Расширение = "7z"			Тогда Возврат "application/x-7z-compressed";
	ИначеЕсли Расширение = "aab"		Тогда Возврат "application/x-authorware-bin";
	ИначеЕсли Расширение = "aac"		Тогда Возврат "audio/x-aac";
	ИначеЕсли Расширение = "aam"		Тогда Возврат "application/x-authorware-map";
	ИначеЕсли Расширение = "aas"		Тогда Возврат "application/x-authorware-seg";
	ИначеЕсли Расширение = "abw"		Тогда Возврат "application/x-abiword";
	ИначеЕсли Расширение = "ac"			Тогда Возврат "application/pkix-attr-cert";
	ИначеЕсли Расширение = "acc"		Тогда Возврат "application/vnd.americandynamics.acc";
	ИначеЕсли Расширение = "ace"		Тогда Возврат "application/x-ace-compressed";
	ИначеЕсли Расширение = "acu"		Тогда Возврат "application/vnd.acucobol";
	ИначеЕсли Расширение = "adp"		Тогда Возврат "audio/adpcm";
	ИначеЕсли Расширение = "aep"		Тогда Возврат "application/vnd.audiograph";
	ИначеЕсли Расширение = "afp"		Тогда Возврат "application/vnd.ibm.modcap";
	ИначеЕсли Расширение = "ahead"		Тогда Возврат "application/vnd.ahead.space";
	ИначеЕсли Расширение = "ai"			Тогда Возврат "application/postscript";
	ИначеЕсли Расширение = "aif"		Тогда Возврат "audio/x-aiff";
	ИначеЕсли Расширение = "air"		Тогда Возврат "application/vnd.adobe.air-application-installer-package+zip";
	ИначеЕсли Расширение = "ait"		Тогда Возврат "application/vnd.dvb.ait";
	ИначеЕсли Расширение = "ami"		Тогда Возврат "application/vnd.amiga.ami";
	ИначеЕсли Расширение = "apk"		Тогда Возврат "application/vnd.android.package-archive";
	ИначеЕсли Расширение = "application"Тогда Возврат "application/x-ms-application";
	ИначеЕсли Расширение = "apr"		Тогда Возврат "application/vnd.lotus-approach";
	ИначеЕсли Расширение = "asf"		Тогда Возврат "video/x-ms-asf";
	ИначеЕсли Расширение = "aso"		Тогда Возврат "application/vnd.accpac.simply.aso";
	ИначеЕсли Расширение = "atc"		Тогда Возврат "application/vnd.acucorp";
	ИначеЕсли Расширение = "atom"		Тогда Возврат "application/atom+xml";
	ИначеЕсли Расширение = "atomcat"	Тогда Возврат "application/atomcat+xml";
	ИначеЕсли Расширение = "atomsvc"	Тогда Возврат "application/atomsvc+xml";
	ИначеЕсли Расширение = "atx"		Тогда Возврат "application/vnd.antix.game-component";
	ИначеЕсли Расширение = "au"			Тогда Возврат "audio/basic";
	ИначеЕсли Расширение = "avi"		Тогда Возврат "video/x-msvideo";
	ИначеЕсли Расширение = "aw"			Тогда Возврат "application/applixware";
	ИначеЕсли Расширение = "azf"		Тогда Возврат "application/vnd.airzip.filesecure.azf";
	ИначеЕсли Расширение = "azs"		Тогда Возврат "application/vnd.airzip.filesecure.azs";
	ИначеЕсли Расширение = "azw"		Тогда Возврат "application/vnd.amazon.ebook";
	ИначеЕсли Расширение = "bcpio"		Тогда Возврат "application/x-bcpio";
	ИначеЕсли Расширение = "bdf"		Тогда Возврат "application/x-font-bdf";
	ИначеЕсли Расширение = "bdm"		Тогда Возврат "application/vnd.syncml.dm+wbxml";
	ИначеЕсли Расширение = "bed"		Тогда Возврат "application/vnd.realvnc.bed";
	ИначеЕсли Расширение = "bh2"		Тогда Возврат "application/vnd.fujitsu.oasysprs";
	ИначеЕсли Расширение = "bin"		Тогда Возврат "application/octet-stream";
	ИначеЕсли Расширение = "bmi"		Тогда Возврат "application/vnd.bmi";
	ИначеЕсли Расширение = "bmp"		Тогда Возврат "image/bmp";
	ИначеЕсли Расширение = "box"		Тогда Возврат "application/vnd.previewsystems.box";
	ИначеЕсли Расширение = "btif"		Тогда Возврат "image/prs.btif";
	ИначеЕсли Расширение = "bz"			Тогда Возврат "application/x-bzip";
	ИначеЕсли Расширение = "bz2"		Тогда Возврат "application/x-bzip2";
	ИначеЕсли Расширение = "c"			Тогда Возврат "text/x-c";
	ИначеЕсли Расширение = "c11amc"		Тогда Возврат "application/vnd.cluetrust.cartomobile-config";
	ИначеЕсли Расширение = "c11amz"		Тогда Возврат "application/vnd.cluetrust.cartomobile-config-pkg";
	ИначеЕсли Расширение = "c4g"		Тогда Возврат "application/vnd.clonk.c4group";
	ИначеЕсли Расширение = "cab"		Тогда Возврат "application/vnd.ms-cab-compressed";
	ИначеЕсли Расширение = "car"		Тогда Возврат "application/vnd.curl.car";
	ИначеЕсли Расширение = "cat"		Тогда Возврат "application/vnd.ms-pki.seccat";
	ИначеЕсли Расширение = "ccxml"		Тогда Возврат "application/ccxml+xml,";
	ИначеЕсли Расширение = "cdbcmsg"	Тогда Возврат "application/vnd.contact.cmsg";
	ИначеЕсли Расширение = "cdkey"		Тогда Возврат "application/vnd.mediastation.cdkey";
	ИначеЕсли Расширение = "cdmia"		Тогда Возврат "application/cdmi-capability";
	ИначеЕсли Расширение = "cdmic"		Тогда Возврат "application/cdmi-container";
	ИначеЕсли Расширение = "cdmid"		Тогда Возврат "application/cdmi-domain";
	ИначеЕсли Расширение = "cdmio"		Тогда Возврат "application/cdmi-object";
	ИначеЕсли Расширение = "cdmiq"		Тогда Возврат "application/cdmi-queue";
	ИначеЕсли Расширение = "cdx"		Тогда Возврат "chemical/x-cdx";
	ИначеЕсли Расширение = "cdxml"		Тогда Возврат "application/vnd.chemdraw+xml";
	ИначеЕсли Расширение = "cdy"		Тогда Возврат "application/vnd.cinderella";
	ИначеЕсли Расширение = "cer"		Тогда Возврат "application/pkix-cert";
	ИначеЕсли Расширение = "cgm"		Тогда Возврат "image/cgm";
	ИначеЕсли Расширение = "chat"		Тогда Возврат "application/x-chat";
	ИначеЕсли Расширение = "chm"		Тогда Возврат "application/vnd.ms-htmlhelp";
	ИначеЕсли Расширение = "chrt"		Тогда Возврат "application/vnd.kde.kchart";
	ИначеЕсли Расширение = "cif"		Тогда Возврат "chemical/x-cif";
	ИначеЕсли Расширение = "cii"		Тогда Возврат "application/vnd.anser-web-certificate-issue-initiation";
	ИначеЕсли Расширение = "cil"		Тогда Возврат "application/vnd.ms-artgalry";
	ИначеЕсли Расширение = "cla"		Тогда Возврат "application/vnd.claymore";
	ИначеЕсли Расширение = "class"		Тогда Возврат "application/java-vm";
	ИначеЕсли Расширение = "clkk"		Тогда Возврат "application/vnd.crick.clicker.keyboard";
	ИначеЕсли Расширение = "clkp"		Тогда Возврат "application/vnd.crick.clicker.palette";
	ИначеЕсли Расширение = "clkt"		Тогда Возврат "application/vnd.crick.clicker.template";
	ИначеЕсли Расширение = "clkw"		Тогда Возврат "application/vnd.crick.clicker.wordbank";
	ИначеЕсли Расширение = "clkx"		Тогда Возврат "application/vnd.crick.clicker";
	ИначеЕсли Расширение = "clp"		Тогда Возврат "application/x-msclip";
	ИначеЕсли Расширение = "cmc"		Тогда Возврат "application/vnd.cosmocaller";
	ИначеЕсли Расширение = "cmdf"		Тогда Возврат "chemical/x-cmdf";
	ИначеЕсли Расширение = "cml"		Тогда Возврат "chemical/x-cml";
	ИначеЕсли Расширение = "cmp"		Тогда Возврат "application/vnd.yellowriver-custom-menu";
	ИначеЕсли Расширение = "cmx"		Тогда Возврат "image/x-cmx";
	ИначеЕсли Расширение = "cod"		Тогда Возврат "application/vnd.rim.cod";
	ИначеЕсли Расширение = "cpio"		Тогда Возврат "application/x-cpio";
	ИначеЕсли Расширение = "cpt"		Тогда Возврат "application/mac-compactpro";
	ИначеЕсли Расширение = "crd"		Тогда Возврат "application/x-mscardfile";
	ИначеЕсли Расширение = "crl"		Тогда Возврат "application/pkix-crl";
	ИначеЕсли Расширение = "cryptonote"	Тогда Возврат "application/vnd.rig.cryptonote";
	ИначеЕсли Расширение = "csh"		Тогда Возврат "application/x-csh";
	ИначеЕсли Расширение = "csml"		Тогда Возврат "chemical/x-csml";
	ИначеЕсли Расширение = "csp"		Тогда Возврат "application/vnd.commonspace";
	ИначеЕсли Расширение = "css"		Тогда Возврат "text/css";
	ИначеЕсли Расширение = "csv"		Тогда Возврат "text/csv";
	ИначеЕсли Расширение = "cu"			Тогда Возврат "application/cu-seeme";
	ИначеЕсли Расширение = "curl"		Тогда Возврат "text/vnd.curl";
	ИначеЕсли Расширение = "cww"		Тогда Возврат "application/prs.cww";
	ИначеЕсли Расширение = "dae"		Тогда Возврат "model/vnd.collada+xml";
	ИначеЕсли Расширение = "daf"		Тогда Возврат "application/vnd.mobius.daf";
	ИначеЕсли Расширение = "davmount"	Тогда Возврат "application/davmount+xml";
	ИначеЕсли Расширение = "dcurl"		Тогда Возврат "text/vnd.curl.dcurl";
	ИначеЕсли Расширение = "dd2"		Тогда Возврат "application/vnd.oma.dd2+xml";
	ИначеЕсли Расширение = "ddd"		Тогда Возврат "application/vnd.fujixerox.ddd";
	ИначеЕсли Расширение = "deb"		Тогда Возврат "application/x-debian-package";
	ИначеЕсли Расширение = "der"		Тогда Возврат "application/x-x509-ca-cert";
	ИначеЕсли Расширение = "dfac"		Тогда Возврат "application/vnd.dreamfactory";
	ИначеЕсли Расширение = "dir"		Тогда Возврат "application/x-director";
	ИначеЕсли Расширение = "dis"		Тогда Возврат "application/vnd.mobius.dis";
	ИначеЕсли Расширение = "djvu"		Тогда Возврат "image/vnd.djvu";
	ИначеЕсли Расширение = "dmg"		Тогда Возврат "application/x-apple-diskimage";
	ИначеЕсли Расширение = "dna"		Тогда Возврат "application/vnd.dna";
	ИначеЕсли Расширение = "doc"		Тогда Возврат "application/msword";
	ИначеЕсли Расширение = "docm"		Тогда Возврат "application/vnd.ms-word.document.macroenabled.12";
	ИначеЕсли Расширение = "docx"		Тогда Возврат "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
	ИначеЕсли Расширение = "dotm"		Тогда Возврат "application/vnd.ms-word.template.macroenabled.12";
	ИначеЕсли Расширение = "dotx"		Тогда Возврат "application/vnd.openxmlformats-officedocument.wordprocessingml.template";
	ИначеЕсли Расширение = "dp"			Тогда Возврат "application/vnd.osgi.dp";
	ИначеЕсли Расширение = "dpg"		Тогда Возврат "application/vnd.dpgraph";
	ИначеЕсли Расширение = "dra"		Тогда Возврат "audio/vnd.dra";
	ИначеЕсли Расширение = "dsc"		Тогда Возврат "text/prs.lines.tag";
	ИначеЕсли Расширение = "dssc"		Тогда Возврат "application/dssc+der";
	ИначеЕсли Расширение = "dtb"		Тогда Возврат "application/x-dtbook+xml";
	ИначеЕсли Расширение = "dtd"		Тогда Возврат "application/xml-dtd";
	ИначеЕсли Расширение = "dts"		Тогда Возврат "audio/vnd.dts";
	ИначеЕсли Расширение = "dtshd"		Тогда Возврат "audio/vnd.dts.hd";
	ИначеЕсли Расширение = "dvi"		Тогда Возврат "application/x-dvi";
	ИначеЕсли Расширение = "dwf"		Тогда Возврат "model/vnd.dwf";
	ИначеЕсли Расширение = "dwg"		Тогда Возврат "image/vnd.dwg";
	ИначеЕсли Расширение = "dxf"		Тогда Возврат "image/vnd.dxf";
	ИначеЕсли Расширение = "dxp"		Тогда Возврат "application/vnd.spotfire.dxp";
	ИначеЕсли Расширение = "ecelp4800"	Тогда Возврат "audio/vnd.nuera.ecelp4800";
	ИначеЕсли Расширение = "ecelp7470"	Тогда Возврат "audio/vnd.nuera.ecelp7470";
	ИначеЕсли Расширение = "ecelp9600"	Тогда Возврат "audio/vnd.nuera.ecelp9600";
	ИначеЕсли Расширение = "edm"		Тогда Возврат "application/vnd.novadigm.edm";
	ИначеЕсли Расширение = "edx"		Тогда Возврат "application/vnd.novadigm.edx";
	ИначеЕсли Расширение = "efif"		Тогда Возврат "application/vnd.picsel";
	ИначеЕсли Расширение = "ei6"		Тогда Возврат "application/vnd.pg.osasli";
	ИначеЕсли Расширение = "eml"		Тогда Возврат "message/rfc822";
	ИначеЕсли Расширение = "emma"		Тогда Возврат "application/emma+xml";
	ИначеЕсли Расширение = "eol"		Тогда Возврат "audio/vnd.digital-winds";
	ИначеЕсли Расширение = "eot"		Тогда Возврат "application/vnd.ms-fontobject";
	ИначеЕсли Расширение = "epub"		Тогда Возврат "application/epub+zip";
	ИначеЕсли Расширение = "es"			Тогда Возврат "application/ecmascript";
	ИначеЕсли Расширение = "es3"		Тогда Возврат "application/vnd.eszigno3+xml";
	ИначеЕсли Расширение = "esf"		Тогда Возврат "application/vnd.epson.esf";
	ИначеЕсли Расширение = "etx"		Тогда Возврат "text/x-setext";
	ИначеЕсли Расширение = "exe"		Тогда Возврат "application/x-msdownload";
	ИначеЕсли Расширение = "exi"		Тогда Возврат "application/exi";
	ИначеЕсли Расширение = "ext"		Тогда Возврат "application/vnd.novadigm.ext";
	ИначеЕсли Расширение = "ez2"		Тогда Возврат "application/vnd.ezpix-album";
	ИначеЕсли Расширение = "ez3"		Тогда Возврат "application/vnd.ezpix-package";
	ИначеЕсли Расширение = "f"			Тогда Возврат "text/x-fortran";
	ИначеЕсли Расширение = "f4v"		Тогда Возврат "video/x-f4v";
	ИначеЕсли Расширение = "fbs"		Тогда Возврат "image/vnd.fastbidsheet";
	ИначеЕсли Расширение = "fcs"		Тогда Возврат "application/vnd.isac.fcs";
	ИначеЕсли Расширение = "fdf"		Тогда Возврат "application/vnd.fdf";
	ИначеЕсли Расширение = "fe_launch"	Тогда Возврат "application/vnd.denovo.fcselayout-link";
	ИначеЕсли Расширение = "fg5"		Тогда Возврат "application/vnd.fujitsu.oasysgp";
	ИначеЕсли Расширение = "fh"			Тогда Возврат "image/x-freehand";
	ИначеЕсли Расширение = "fig"		Тогда Возврат "application/x-xfig";
	ИначеЕсли Расширение = "fli"		Тогда Возврат "video/x-fli";
	ИначеЕсли Расширение = "flo"		Тогда Возврат "application/vnd.micrografx.flo";
	ИначеЕсли Расширение = "flv"		Тогда Возврат "video/x-flv";
	ИначеЕсли Расширение = "flw"		Тогда Возврат "application/vnd.kde.kivio";
	ИначеЕсли Расширение = "flx"		Тогда Возврат "text/vnd.fmi.flexstor";
	ИначеЕсли Расширение = "fly"		Тогда Возврат "text/vnd.fly";
	ИначеЕсли Расширение = "fm"			Тогда Возврат "application/vnd.framemaker";
	ИначеЕсли Расширение = "fnc"		Тогда Возврат "application/vnd.frogans.fnc";
	ИначеЕсли Расширение = "fpx"		Тогда Возврат "image/vnd.fpx";
	ИначеЕсли Расширение = "fsc"		Тогда Возврат "application/vnd.fsc.weblaunch";
	ИначеЕсли Расширение = "fst"		Тогда Возврат "image/vnd.fst";
	ИначеЕсли Расширение = "ftc"		Тогда Возврат "application/vnd.fluxtime.clip";
	ИначеЕсли Расширение = "fti"		Тогда Возврат "application/vnd.anser-web-funds-transfer-initiation";
	ИначеЕсли Расширение = "fvt"		Тогда Возврат "video/vnd.fvt";
	ИначеЕсли Расширение = "fxp"		Тогда Возврат "application/vnd.adobe.fxp";
	ИначеЕсли Расширение = "fzs"		Тогда Возврат "application/vnd.fuzzysheet";
	ИначеЕсли Расширение = "g2w"		Тогда Возврат "application/vnd.geoplan";
	ИначеЕсли Расширение = "g3"			Тогда Возврат "image/g3fax";
	ИначеЕсли Расширение = "g3w"		Тогда Возврат "application/vnd.geospace";
	ИначеЕсли Расширение = "gac"		Тогда Возврат "application/vnd.groove-account";
	ИначеЕсли Расширение = "gdl"		Тогда Возврат "model/vnd.gdl";
	ИначеЕсли Расширение = "geo"		Тогда Возврат "application/vnd.dynageo";
	ИначеЕсли Расширение = "gex"		Тогда Возврат "application/vnd.geometry-explorer";
	ИначеЕсли Расширение = "ggb"		Тогда Возврат "application/vnd.geogebra.file";
	ИначеЕсли Расширение = "ggt"		Тогда Возврат "application/vnd.geogebra.tool";
	ИначеЕсли Расширение = "ghf"		Тогда Возврат "application/vnd.groove-help";
	ИначеЕсли Расширение = "gif"		Тогда Возврат "image/gif";
	ИначеЕсли Расширение = "gim"		Тогда Возврат "application/vnd.groove-identity-message";
	ИначеЕсли Расширение = "gmx"		Тогда Возврат "application/vnd.gmx";
	ИначеЕсли Расширение = "gnumeric"	Тогда Возврат "application/x-gnumeric";
	ИначеЕсли Расширение = "gph"		Тогда Возврат "application/vnd.flographit";
	ИначеЕсли Расширение = "gqf"		Тогда Возврат "application/vnd.grafeq";
	ИначеЕсли Расширение = "gram"		Тогда Возврат "application/srgs";
	ИначеЕсли Расширение = "grv"		Тогда Возврат "application/vnd.groove-injector";
	ИначеЕсли Расширение = "grxml"		Тогда Возврат "application/srgs+xml";
	ИначеЕсли Расширение = "gsf"		Тогда Возврат "application/x-font-ghostscript";
	ИначеЕсли Расширение = "gtar"		Тогда Возврат "application/x-gtar";
	ИначеЕсли Расширение = "gtm"		Тогда Возврат "application/vnd.groove-tool-message";
	ИначеЕсли Расширение = "gtw"		Тогда Возврат "model/vnd.gtw";
	ИначеЕсли Расширение = "gv"			Тогда Возврат "text/vnd.graphviz";
	ИначеЕсли Расширение = "gxt"		Тогда Возврат "application/vnd.geonext";
	ИначеЕсли Расширение = "h261"		Тогда Возврат "video/h261";
	ИначеЕсли Расширение = "h263"		Тогда Возврат "video/h263";
	ИначеЕсли Расширение = "h264"		Тогда Возврат "video/h264";
	ИначеЕсли Расширение = "hal"		Тогда Возврат "application/vnd.hal+xml";
	ИначеЕсли Расширение = "hbci"		Тогда Возврат "application/vnd.hbci";
	ИначеЕсли Расширение = "hdf"		Тогда Возврат "application/x-hdf";
	ИначеЕсли Расширение = "hlp"		Тогда Возврат "application/winhlp";
	ИначеЕсли Расширение = "hpgl"		Тогда Возврат "application/vnd.hp-hpgl";
	ИначеЕсли Расширение = "hpid"		Тогда Возврат "application/vnd.hp-hpid";
	ИначеЕсли Расширение = "hps"		Тогда Возврат "application/vnd.hp-hps";
	ИначеЕсли Расширение = "hqx"		Тогда Возврат "application/mac-binhex40";
	ИначеЕсли Расширение = "htke"		Тогда Возврат "application/vnd.kenameaapp";
	ИначеЕсли Расширение = "html"		Тогда Возврат "text/html";
	ИначеЕсли Расширение = "hvd"		Тогда Возврат "application/vnd.yamaha.hv-dic";
	ИначеЕсли Расширение = "hvp"		Тогда Возврат "application/vnd.yamaha.hv-voice";
	ИначеЕсли Расширение = "hvs"		Тогда Возврат "application/vnd.yamaha.hv-script";
	ИначеЕсли Расширение = "i2g"		Тогда Возврат "application/vnd.intergeo";
	ИначеЕсли Расширение = "icc"		Тогда Возврат "application/vnd.iccprofile";
	ИначеЕсли Расширение = "ice"		Тогда Возврат "x-conference/x-cooltalk";
	ИначеЕсли Расширение = "ico"		Тогда Возврат "image/x-icon";
	ИначеЕсли Расширение = "ics"		Тогда Возврат "text/calendar";
	ИначеЕсли Расширение = "ief"		Тогда Возврат "image/ief";
	ИначеЕсли Расширение = "ifm"		Тогда Возврат "application/vnd.shana.informed.formdata";
	ИначеЕсли Расширение = "igl"		Тогда Возврат "application/vnd.igloader";
	ИначеЕсли Расширение = "igm"		Тогда Возврат "application/vnd.insors.igm";
	ИначеЕсли Расширение = "igs"		Тогда Возврат "model/iges";
	ИначеЕсли Расширение = "igx"		Тогда Возврат "application/vnd.micrografx.igx";
	ИначеЕсли Расширение = "iif"		Тогда Возврат "application/vnd.shana.informed.interchange";
	ИначеЕсли Расширение = "imp"		Тогда Возврат "application/vnd.accpac.simply.imp";
	ИначеЕсли Расширение = "ims"		Тогда Возврат "application/vnd.ms-ims";
	ИначеЕсли Расширение = "ipfix"		Тогда Возврат "application/ipfix";
	ИначеЕсли Расширение = "ipk"		Тогда Возврат "application/vnd.shana.informed.package";
	ИначеЕсли Расширение = "irm"		Тогда Возврат "application/vnd.ibm.rights-management";
	ИначеЕсли Расширение = "irp"		Тогда Возврат "application/vnd.irepository.package+xml";
	ИначеЕсли Расширение = "itp"		Тогда Возврат "application/vnd.shana.informed.formtemplate";
	ИначеЕсли Расширение = "ivp"		Тогда Возврат "application/vnd.immervision-ivp";
	ИначеЕсли Расширение = "ivu"		Тогда Возврат "application/vnd.immervision-ivu";
	ИначеЕсли Расширение = "jad"		Тогда Возврат "text/vnd.sun.j2me.app-descriptor";
	ИначеЕсли Расширение = "jam"		Тогда Возврат "application/vnd.jam";
	ИначеЕсли Расширение = "jar"		Тогда Возврат "application/java-archive";
	ИначеЕсли Расширение = "java"		Тогда Возврат "text/x-java-source,java";
	ИначеЕсли Расширение = "jisp"		Тогда Возврат "application/vnd.jisp";
	ИначеЕсли Расширение = "jlt"		Тогда Возврат "application/vnd.hp-jlyt";
	ИначеЕсли Расширение = "jnlp"		Тогда Возврат "application/x-java-jnlp-file";
	ИначеЕсли Расширение = "joda"		Тогда Возврат "application/vnd.joost.joda-archive";
	ИначеЕсли Расширение = "jpg"		Тогда Возврат "image/jpeg";
	ИначеЕсли Расширение = "jpeg"		Тогда Возврат "image/jpeg";
	ИначеЕсли Расширение = "jpgv"		Тогда Возврат "video/jpeg";
	ИначеЕсли Расширение = "jpm"		Тогда Возврат "video/jpm";
	ИначеЕсли Расширение = "js"			Тогда Возврат "application/javascript";
	ИначеЕсли Расширение = "json"		Тогда Возврат "application/json";
	ИначеЕсли Расширение = "karbon"		Тогда Возврат "application/vnd.kde.karbon";
	ИначеЕсли Расширение = "kfo"		Тогда Возврат "application/vnd.kde.kformula";
	ИначеЕсли Расширение = "kia"		Тогда Возврат "application/vnd.kidspiration";
	ИначеЕсли Расширение = "kml"		Тогда Возврат "application/vnd.google-earth.kml+xml";
	ИначеЕсли Расширение = "kmz"		Тогда Возврат "application/vnd.google-earth.kmz";
	ИначеЕсли Расширение = "kne"		Тогда Возврат "application/vnd.kinar";
	ИначеЕсли Расширение = "kon"		Тогда Возврат "application/vnd.kde.kontour";
	ИначеЕсли Расширение = "kpr"		Тогда Возврат "application/vnd.kde.kpresenter";
	ИначеЕсли Расширение = "ksp"		Тогда Возврат "application/vnd.kde.kspread";
	ИначеЕсли Расширение = "ktx"		Тогда Возврат "image/ktx";
	ИначеЕсли Расширение = "ktz"		Тогда Возврат "application/vnd.kahootz";
	ИначеЕсли Расширение = "kwd"		Тогда Возврат "application/vnd.kde.kword";
	ИначеЕсли Расширение = "lasxml"		Тогда Возврат "application/vnd.las.las+xml";
	ИначеЕсли Расширение = "latex"		Тогда Возврат "application/x-latex";
	ИначеЕсли Расширение = "lbd"		Тогда Возврат "application/vnd.llamagraphics.life-balance.desktop";
	ИначеЕсли Расширение = "lbe"		Тогда Возврат "application/vnd.llamagraphics.life-balance.exchange+xml";
	ИначеЕсли Расширение = "les"		Тогда Возврат "application/vnd.hhe.lesson-player";
	ИначеЕсли Расширение = "link66"		Тогда Возврат "application/vnd.route66.link66+xml";
	ИначеЕсли Расширение = "lrm"		Тогда Возврат "application/vnd.ms-lrm";
	ИначеЕсли Расширение = "ltf"		Тогда Возврат "application/vnd.frogans.ltf";
	ИначеЕсли Расширение = "lvp"		Тогда Возврат "audio/vnd.lucent.voice";
	ИначеЕсли Расширение = "lwp"		Тогда Возврат "application/vnd.lotus-wordpro";
	ИначеЕсли Расширение = "m21"		Тогда Возврат "application/mp21";
	ИначеЕсли Расширение = "m3u"		Тогда Возврат "audio/x-mpegurl";
	ИначеЕсли Расширение = "m3u8"		Тогда Возврат "application/vnd.apple.mpegurl";
	ИначеЕсли Расширение = "m4v"		Тогда Возврат "video/x-m4v";
	ИначеЕсли Расширение = "ma"			Тогда Возврат "application/mathematica";
	ИначеЕсли Расширение = "mads"		Тогда Возврат "application/mads+xml";
	ИначеЕсли Расширение = "mag"		Тогда Возврат "application/vnd.ecowin.chart";
	ИначеЕсли Расширение = "mathml"		Тогда Возврат "application/mathml+xml";
	ИначеЕсли Расширение = "mbk"		Тогда Возврат "application/vnd.mobius.mbk";
	ИначеЕсли Расширение = "mbox"		Тогда Возврат "application/mbox";
	ИначеЕсли Расширение = "mc1"		Тогда Возврат "application/vnd.medcalcdata";
	ИначеЕсли Расширение = "mcd"		Тогда Возврат "application/vnd.mcd";
	ИначеЕсли Расширение = "mcurl"		Тогда Возврат "text/vnd.curl.mcurl";
	ИначеЕсли Расширение = "mdb"		Тогда Возврат "application/x-msaccess";
	ИначеЕсли Расширение = "mdi"		Тогда Возврат "image/vnd.ms-modi";
	ИначеЕсли Расширение = "meta4"		Тогда Возврат "application/metalink4+xml";
	ИначеЕсли Расширение = "mets"		Тогда Возврат "application/mets+xml";
	ИначеЕсли Расширение = "mfm"		Тогда Возврат "application/vnd.mfmp";
	ИначеЕсли Расширение = "mgp"		Тогда Возврат "application/vnd.osgeo.mapguide.package";
	ИначеЕсли Расширение = "mgz"		Тогда Возврат "application/vnd.proteus.magazine";
	ИначеЕсли Расширение = "mid"		Тогда Возврат "audio/midi";
	ИначеЕсли Расширение = "mif"		Тогда Возврат "application/vnd.mif";
	ИначеЕсли Расширение = "mj2"		Тогда Возврат "video/mj2";
	ИначеЕсли Расширение = "mlp"		Тогда Возврат "application/vnd.dolby.mlp";
	ИначеЕсли Расширение = "mmd"		Тогда Возврат "application/vnd.chipnuts.karaoke-mmd";
	ИначеЕсли Расширение = "mmf"		Тогда Возврат "application/vnd.smaf";
	ИначеЕсли Расширение = "mmr"		Тогда Возврат "image/vnd.fujixerox.edmics-mmr";
	ИначеЕсли Расширение = "mny"		Тогда Возврат "application/x-msmoney";
	ИначеЕсли Расширение = "mods"		Тогда Возврат "application/mods+xml";
	ИначеЕсли Расширение = "movie"		Тогда Возврат "video/x-sgi-movie";
	ИначеЕсли Расширение = "mp4"		Тогда Возврат "application/mp4";
	ИначеЕсли Расширение = "mp4"		Тогда Возврат "video/mp4";
	ИначеЕсли Расширение = "mp4a"		Тогда Возврат "audio/mp4";
	ИначеЕсли Расширение = "mpc"		Тогда Возврат "application/vnd.mophun.certificate";
	ИначеЕсли Расширение = "mpeg"		Тогда Возврат "video/mpeg";
	ИначеЕсли Расширение = "mpga"		Тогда Возврат "audio/mpeg";
	ИначеЕсли Расширение = "mpkg"		Тогда Возврат "application/vnd.apple.installer+xml";
	ИначеЕсли Расширение = "mpm"		Тогда Возврат "application/vnd.blueice.multipass";
	ИначеЕсли Расширение = "mpn"		Тогда Возврат "application/vnd.mophun.application";
	ИначеЕсли Расширение = "mpp"		Тогда Возврат "application/vnd.ms-project";
	ИначеЕсли Расширение = "mpy"		Тогда Возврат "application/vnd.ibm.minipay";
	ИначеЕсли Расширение = "mqy"		Тогда Возврат "application/vnd.mobius.mqy";
	ИначеЕсли Расширение = "mrc"		Тогда Возврат "application/marc";
	ИначеЕсли Расширение = "mrcx"		Тогда Возврат "application/marcxml+xml";
	ИначеЕсли Расширение = "mscml"		Тогда Возврат "application/mediaservercontrol+xml";
	ИначеЕсли Расширение = "mseq"		Тогда Возврат "application/vnd.mseq";
	ИначеЕсли Расширение = "msf"		Тогда Возврат "application/vnd.epson.msf";
	ИначеЕсли Расширение = "msh"		Тогда Возврат "model/mesh";
	ИначеЕсли Расширение = "msl"		Тогда Возврат "application/vnd.mobius.msl";
	ИначеЕсли Расширение = "msty"		Тогда Возврат "application/vnd.muvee.style";
	ИначеЕсли Расширение = "mts"		Тогда Возврат "model/vnd.mts";
	ИначеЕсли Расширение = "mus"		Тогда Возврат "application/vnd.musician";
	ИначеЕсли Расширение = "musicxml"	Тогда Возврат "application/vnd.recordare.musicxml+xml";
	ИначеЕсли Расширение = "mvb"		Тогда Возврат "application/x-msmediaview";
	ИначеЕсли Расширение = "mwf"		Тогда Возврат "application/vnd.mfer";
	ИначеЕсли Расширение = "mxf"		Тогда Возврат "application/mxf";
	ИначеЕсли Расширение = "mxl"		Тогда Возврат "application/vnd.recordare.musicxml";
	ИначеЕсли Расширение = "mxml"		Тогда Возврат "application/xv+xml";
	ИначеЕсли Расширение = "mxs"		Тогда Возврат "application/vnd.triscape.mxs";
	ИначеЕсли Расширение = "mxu"		Тогда Возврат "video/vnd.mpegurl";
	ИначеЕсли Расширение = "n"			Тогда Возврат "gage	application/vnd.nokia.n-gage.symbian.install";
	ИначеЕсли Расширение = "n3"			Тогда Возврат "text/n3";
	ИначеЕсли Расширение = "nbp"		Тогда Возврат "application/vnd.wolfram.player";
	ИначеЕсли Расширение = "nc"			Тогда Возврат "application/x-netcdf";
	ИначеЕсли Расширение = "ncx"		Тогда Возврат "application/x-dtbncx+xml";
	ИначеЕсли Расширение = "ngdat"		Тогда Возврат "application/vnd.nokia.n-gage.data";
	ИначеЕсли Расширение = "nlu"		Тогда Возврат "application/vnd.neurolanguage.nlu";
	ИначеЕсли Расширение = "nml"		Тогда Возврат "application/vnd.enliven";
	ИначеЕсли Расширение = "nnd"		Тогда Возврат "application/vnd.noblenet-directory";
	ИначеЕсли Расширение = "nns"		Тогда Возврат "application/vnd.noblenet-sealer";
	ИначеЕсли Расширение = "nnw"		Тогда Возврат "application/vnd.noblenet-web";
	ИначеЕсли Расширение = "npx"		Тогда Возврат "image/vnd.net-fpx";
	ИначеЕсли Расширение = "nsf"		Тогда Возврат "application/vnd.lotus-notes";
	ИначеЕсли Расширение = "oa2"		Тогда Возврат "application/vnd.fujitsu.oasys2";
	ИначеЕсли Расширение = "oa3"		Тогда Возврат "application/vnd.fujitsu.oasys3";
	ИначеЕсли Расширение = "oas"		Тогда Возврат "application/vnd.fujitsu.oasys";
	ИначеЕсли Расширение = "obd"		Тогда Возврат "application/x-msbinder";
	ИначеЕсли Расширение = "oda"		Тогда Возврат "application/oda";
	ИначеЕсли Расширение = "odb"		Тогда Возврат "application/vnd.oasis.opendocument.database";
	ИначеЕсли Расширение = "odc"		Тогда Возврат "application/vnd.oasis.opendocument.chart";
	ИначеЕсли Расширение = "odf"		Тогда Возврат "application/vnd.oasis.opendocument.formula";
	ИначеЕсли Расширение = "odft"		Тогда Возврат "application/vnd.oasis.opendocument.formula-template";
	ИначеЕсли Расширение = "odg"		Тогда Возврат "application/vnd.oasis.opendocument.graphics";
	ИначеЕсли Расширение = "odi"		Тогда Возврат "application/vnd.oasis.opendocument.image";
	ИначеЕсли Расширение = "odm"		Тогда Возврат "application/vnd.oasis.opendocument.text-master";
	ИначеЕсли Расширение = "odp"		Тогда Возврат "application/vnd.oasis.opendocument.presentation";
	ИначеЕсли Расширение = "ods"		Тогда Возврат "application/vnd.oasis.opendocument.spreadsheet";
	ИначеЕсли Расширение = "odt"		Тогда Возврат "application/vnd.oasis.opendocument.text";
	ИначеЕсли Расширение = "oga"		Тогда Возврат "audio/ogg";
	ИначеЕсли Расширение = "ogv"		Тогда Возврат "video/ogg";
	ИначеЕсли Расширение = "ogx"		Тогда Возврат "application/ogg";
	ИначеЕсли Расширение = "onetoc"		Тогда Возврат "application/onenote";
	ИначеЕсли Расширение = "opf"		Тогда Возврат "application/oebps-package+xml";
	ИначеЕсли Расширение = "org"		Тогда Возврат "application/vnd.lotus-organizer";
	ИначеЕсли Расширение = "osf"		Тогда Возврат "application/vnd.yamaha.openscoreformat";
	ИначеЕсли Расширение = "osfpvg"		Тогда Возврат "application/vnd.yamaha.openscoreformat.osfpvg+xml";
	ИначеЕсли Расширение = "otc"		Тогда Возврат "application/vnd.oasis.opendocument.chart-template";
	ИначеЕсли Расширение = "otf"		Тогда Возврат "application/x-font-otf";
	ИначеЕсли Расширение = "otg"		Тогда Возврат "application/vnd.oasis.opendocument.graphics-template";
	ИначеЕсли Расширение = "oth"		Тогда Возврат "application/vnd.oasis.opendocument.text-web";
	ИначеЕсли Расширение = "oti"		Тогда Возврат "application/vnd.oasis.opendocument.image-template";
	ИначеЕсли Расширение = "otp"		Тогда Возврат "application/vnd.oasis.opendocument.presentation-template";
	ИначеЕсли Расширение = "ots"		Тогда Возврат "application/vnd.oasis.opendocument.spreadsheet-template";
	ИначеЕсли Расширение = "ott"		Тогда Возврат "application/vnd.oasis.opendocument.text-template";
	ИначеЕсли Расширение = "oxt"		Тогда Возврат "application/vnd.openofficeorg.extension";
	ИначеЕсли Расширение = "p"			Тогда Возврат "text/x-pascal";
	ИначеЕсли Расширение = "p10"		Тогда Возврат "application/pkcs10";
	ИначеЕсли Расширение = "p12"		Тогда Возврат "application/x-pkcs12";
	ИначеЕсли Расширение = "p7b"		Тогда Возврат "application/x-pkcs7-certificates";
	ИначеЕсли Расширение = "p7m"		Тогда Возврат "application/pkcs7-mime";
	ИначеЕсли Расширение = "p7r"		Тогда Возврат "application/x-pkcs7-certreqresp";
	ИначеЕсли Расширение = "p7s"		Тогда Возврат "application/pkcs7-signature";
	ИначеЕсли Расширение = "p8"			Тогда Возврат "application/pkcs8";
	ИначеЕсли Расширение = "par"		Тогда Возврат "text/plain-bas";
	ИначеЕсли Расширение = "paw"		Тогда Возврат "application/vnd.pawaafile";
	ИначеЕсли Расширение = "pbd"		Тогда Возврат "application/vnd.powerbuilder6";
	ИначеЕсли Расширение = "pbm"		Тогда Возврат "image/x-portable-bitmap";
	ИначеЕсли Расширение = "pcf"		Тогда Возврат "application/x-font-pcf";
	ИначеЕсли Расширение = "pcl"		Тогда Возврат "application/vnd.hp-pcl";
	ИначеЕсли Расширение = "pclxl"		Тогда Возврат "application/vnd.hp-pclxl";
	ИначеЕсли Расширение = "pcurl"		Тогда Возврат "application/vnd.curl.pcurl";
	ИначеЕсли Расширение = "pcx"		Тогда Возврат "image/x-pcx";
	ИначеЕсли Расширение = "pdb"		Тогда Возврат "application/vnd.palm";
	ИначеЕсли Расширение = "pdf"		Тогда Возврат "application/pdf";
	ИначеЕсли Расширение = "pfa"		Тогда Возврат "application/x-font-type1";
	ИначеЕсли Расширение = "pfr"		Тогда Возврат "application/font-tdpfr";
	ИначеЕсли Расширение = "pgm"		Тогда Возврат "image/x-portable-graymap";
	ИначеЕсли Расширение = "pgn"		Тогда Возврат "application/x-chess-pgn";
	ИначеЕсли Расширение = "pgp"		Тогда Возврат "application/pgp-encrypted";
	ИначеЕсли Расширение = "pgp"		Тогда Возврат "application/pgp-signature";
	ИначеЕсли Расширение = "pic"		Тогда Возврат "image/x-pict";
	ИначеЕсли Расширение = "pjpeg"		Тогда Возврат "image/pjpeg";
	ИначеЕсли Расширение = "pki"		Тогда Возврат "application/pkixcmp";
	ИначеЕсли Расширение = "pkipath"	Тогда Возврат "application/pkix-pkipath";
	ИначеЕсли Расширение = "plb"		Тогда Возврат "application/vnd.3gpp.pic-bw-large";
	ИначеЕсли Расширение = "plc"		Тогда Возврат "application/vnd.mobius.plc";
	ИначеЕсли Расширение = "plf"		Тогда Возврат "application/vnd.pocketlearn";
	ИначеЕсли Расширение = "pls"		Тогда Возврат "application/pls+xml";
	ИначеЕсли Расширение = "pml"		Тогда Возврат "application/vnd.ctc-posml";
	ИначеЕсли Расширение = "png"		Тогда Возврат "image/png";
	ИначеЕсли Расширение = "png"		Тогда Возврат "image/x-png";
	ИначеЕсли Расширение = "png"		Тогда Возврат "image/x-citrix-png";
	ИначеЕсли Расширение = "pnm"		Тогда Возврат "image/x-portable-anymap";
	ИначеЕсли Расширение = "portpkg"	Тогда Возврат "application/vnd.macports.portpkg";
	ИначеЕсли Расширение = "potm"		Тогда Возврат "application/vnd.ms-powerpoint.template.macroenabled.12";
	ИначеЕсли Расширение = "potx"		Тогда Возврат "application/vnd.openxmlformats-officedocument.presentationml.template";
	ИначеЕсли Расширение = "ppam"		Тогда Возврат "application/vnd.ms-powerpoint.addin.macroenabled.12";
	ИначеЕсли Расширение = "ppd"		Тогда Возврат "application/vnd.cups-ppd";
	ИначеЕсли Расширение = "ppm"		Тогда Возврат "image/x-portable-pixmap";
	ИначеЕсли Расширение = "ppsm"		Тогда Возврат "application/vnd.ms-powerpoint.slideshow.macroenabled.12";
	ИначеЕсли Расширение = "ppsx"		Тогда Возврат "application/vnd.openxmlformats-officedocument.presentationml.slideshow";
	ИначеЕсли Расширение = "ppt"		Тогда Возврат "application/vnd.ms-powerpoint";
	ИначеЕсли Расширение = "pptm"		Тогда Возврат "application/vnd.ms-powerpoint.presentation.macroenabled.12";
	ИначеЕсли Расширение = "pptx"		Тогда Возврат "application/vnd.openxmlformats-officedocument.presentationml.presentation";
	ИначеЕсли Расширение = "prc"		Тогда Возврат "application/x-mobipocket-ebook";
	ИначеЕсли Расширение = "pre"		Тогда Возврат "application/vnd.lotus-freelance";
	ИначеЕсли Расширение = "prf"		Тогда Возврат "application/pics-rules";
	ИначеЕсли Расширение = "psb"		Тогда Возврат "application/vnd.3gpp.pic-bw-small";
	ИначеЕсли Расширение = "psd"		Тогда Возврат "image/vnd.adobe.photoshop";
	ИначеЕсли Расширение = "psf"		Тогда Возврат "application/x-font-linux-psf";
	ИначеЕсли Расширение = "pskcxml"	Тогда Возврат "application/pskc+xml";
	ИначеЕсли Расширение = "ptid"		Тогда Возврат "application/vnd.pvi.ptid1";
	ИначеЕсли Расширение = "pub"		Тогда Возврат "application/x-mspublisher";
	ИначеЕсли Расширение = "pvb"		Тогда Возврат "application/vnd.3gpp.pic-bw-var";
	ИначеЕсли Расширение = "pwn"		Тогда Возврат "application/vnd.3m.post-it-notes";
	ИначеЕсли Расширение = "pya"		Тогда Возврат "audio/vnd.ms-playready.media.pya";
	ИначеЕсли Расширение = "pyv"		Тогда Возврат "video/vnd.ms-playready.media.pyv";
	ИначеЕсли Расширение = "qam"		Тогда Возврат "application/vnd.epson.quickanime";
	ИначеЕсли Расширение = "qbo"		Тогда Возврат "application/vnd.intu.qbo";
	ИначеЕсли Расширение = "qfx"		Тогда Возврат "application/vnd.intu.qfx";
	ИначеЕсли Расширение = "qps"		Тогда Возврат "application/vnd.publishare-delta-tree";
	ИначеЕсли Расширение = "qt"			Тогда Возврат "video/quicktime";
	ИначеЕсли Расширение = "qxd"		Тогда Возврат "application/vnd.quark.quarkxpress";
	ИначеЕсли Расширение = "ram"		Тогда Возврат "audio/x-pn-realaudio";
	ИначеЕсли Расширение = "rar"		Тогда Возврат "application/x-rar-compressed";
	ИначеЕсли Расширение = "ras"		Тогда Возврат "image/x-cmu-raster";
	ИначеЕсли Расширение = "rcprofile"	Тогда Возврат "application/vnd.ipunplugged.rcprofile";
	ИначеЕсли Расширение = "rdf"		Тогда Возврат "application/rdf+xml";
	ИначеЕсли Расширение = "rdz"		Тогда Возврат "application/vnd.data-vision.rdz";
	ИначеЕсли Расширение = "rep"		Тогда Возврат "application/vnd.businessobjects";
	ИначеЕсли Расширение = "res"		Тогда Возврат "application/x-dtbresource+xml";
	ИначеЕсли Расширение = "rgb"		Тогда Возврат "image/x-rgb";
	ИначеЕсли Расширение = "rif"		Тогда Возврат "application/reginfo+xml";
	ИначеЕсли Расширение = "rip"		Тогда Возврат "audio/vnd.rip";
	ИначеЕсли Расширение = "rl"			Тогда Возврат "application/resource-lists+xml";
	ИначеЕсли Расширение = "rlc"		Тогда Возврат "image/vnd.fujixerox.edmics-rlc";
	ИначеЕсли Расширение = "rld"		Тогда Возврат "application/resource-lists-diff+xml";
	ИначеЕсли Расширение = "rm"			Тогда Возврат "application/vnd.rn-realmedia";
	ИначеЕсли Расширение = "rmp"		Тогда Возврат "audio/x-pn-realaudio-plugin";
	ИначеЕсли Расширение = "rms"		Тогда Возврат "application/vnd.jcp.javame.midlet-rms";
	ИначеЕсли Расширение = "rnc"		Тогда Возврат "application/relax-ng-compact-syntax";
	ИначеЕсли Расширение = "rp9"		Тогда Возврат "application/vnd.cloanto.rp9";
	ИначеЕсли Расширение = "rpss"		Тогда Возврат "application/vnd.nokia.radio-presets";
	ИначеЕсли Расширение = "rpst"		Тогда Возврат "application/vnd.nokia.radio-preset";
	ИначеЕсли Расширение = "rq"			Тогда Возврат "application/sparql-query";
	ИначеЕсли Расширение = "rs"			Тогда Возврат "application/rls-services+xml";
	ИначеЕсли Расширение = "rsd"		Тогда Возврат "application/rsd+xml";
	ИначеЕсли Расширение = "rss"		Тогда Возврат "application/rss+xml";
	ИначеЕсли Расширение = "rtf"		Тогда Возврат "application/rtf";
	ИначеЕсли Расширение = "rtx"		Тогда Возврат "text/richtext";
	ИначеЕсли Расширение = "s"			Тогда Возврат "text/x-asm";
	ИначеЕсли Расширение = "saf"		Тогда Возврат "application/vnd.yamaha.smaf-audio";
	ИначеЕсли Расширение = "sbml"		Тогда Возврат "application/sbml+xml";
	ИначеЕсли Расширение = "sc"			Тогда Возврат "application/vnd.ibm.secure-container";
	ИначеЕсли Расширение = "scd"		Тогда Возврат "application/x-msschedule";
	ИначеЕсли Расширение = "scm"		Тогда Возврат "application/vnd.lotus-screencam";
	ИначеЕсли Расширение = "scq"		Тогда Возврат "application/scvp-cv-request";
	ИначеЕсли Расширение = "scs"		Тогда Возврат "application/scvp-cv-response";
	ИначеЕсли Расширение = "scurl"		Тогда Возврат "text/vnd.curl.scurl";
	ИначеЕсли Расширение = "sda"		Тогда Возврат "application/vnd.stardivision.draw";
	ИначеЕсли Расширение = "sdc"		Тогда Возврат "application/vnd.stardivision.calc";
	ИначеЕсли Расширение = "sdd"		Тогда Возврат "application/vnd.stardivision.impress";
	ИначеЕсли Расширение = "sdkm"		Тогда Возврат "application/vnd.solent.sdkm+xml";
	ИначеЕсли Расширение = "sdp"		Тогда Возврат "application/sdp";
	ИначеЕсли Расширение = "sdw"		Тогда Возврат "application/vnd.stardivision.writer";
	ИначеЕсли Расширение = "see"		Тогда Возврат "application/vnd.seemail";
	ИначеЕсли Расширение = "seed"		Тогда Возврат "application/vnd.fdsn.seed";
	ИначеЕсли Расширение = "sema"		Тогда Возврат "application/vnd.sema";
	ИначеЕсли Расширение = "semd"		Тогда Возврат "application/vnd.semd";
	ИначеЕсли Расширение = "semf"		Тогда Возврат "application/vnd.semf";
	ИначеЕсли Расширение = "ser"		Тогда Возврат "application/java-serialized-object";
	ИначеЕсли Расширение = "setpay"		Тогда Возврат "application/set-payment-initiation";
	ИначеЕсли Расширение = "setreg"		Тогда Возврат "application/set-registration-initiation";
	ИначеЕсли Расширение = "sfd"		Тогда Возврат "application/vnd.hydrostatix.sof-data";
	ИначеЕсли Расширение = "hdstx"		Тогда Возврат "application/vnd.hydrostatix.sof-data";
	ИначеЕсли Расширение = "sfs"		Тогда Возврат "application/vnd.spotfire.sfs";
	ИначеЕсли Расширение = "sgl"		Тогда Возврат "application/vnd.stardivision.writer-global";
	ИначеЕсли Расширение = "sgml"		Тогда Возврат "text/sgml";
	ИначеЕсли Расширение = "sh"			Тогда Возврат "application/x-sh";
	ИначеЕсли Расширение = "shar"		Тогда Возврат "application/x-shar";
	ИначеЕсли Расширение = "shf"		Тогда Возврат "application/shf+xml";
	ИначеЕсли Расширение = "sis"		Тогда Возврат "application/vnd.symbian.install";
	ИначеЕсли Расширение = "sit"		Тогда Возврат "application/x-stuffit";
	ИначеЕсли Расширение = "sitx"		Тогда Возврат "application/x-stuffitx";
	ИначеЕсли Расширение = "skp"		Тогда Возврат "application/vnd.koan";
	ИначеЕсли Расширение = "sldm"		Тогда Возврат "application/vnd.ms-powerpoint.slide.macroenabled.12";
	ИначеЕсли Расширение = "sldx"		Тогда Возврат "application/vnd.openxmlformats-officedocument.presentationml.slide";
	ИначеЕсли Расширение = "slt"		Тогда Возврат "application/vnd.epson.salt";
	ИначеЕсли Расширение = "sm"			Тогда Возврат "application/vnd.stepmania.stepchart";
	ИначеЕсли Расширение = "smf"		Тогда Возврат "application/vnd.stardivision.math";
	ИначеЕсли Расширение = "smi"		Тогда Возврат "application/smil+xml";
	ИначеЕсли Расширение = "snf"		Тогда Возврат "application/x-font-snf";
	ИначеЕсли Расширение = "spf"		Тогда Возврат "application/vnd.yamaha.smaf-phrase";
	ИначеЕсли Расширение = "spl"		Тогда Возврат "application/x-futuresplash";
	ИначеЕсли Расширение = "spot"		Тогда Возврат "text/vnd.in3d.spot";
	ИначеЕсли Расширение = "spp"		Тогда Возврат "application/scvp-vp-response";
	ИначеЕсли Расширение = "spq"		Тогда Возврат "application/scvp-vp-request";
	ИначеЕсли Расширение = "src"		Тогда Возврат "application/x-wais-source";
	ИначеЕсли Расширение = "sru"		Тогда Возврат "application/sru+xml";
	ИначеЕсли Расширение = "srx"		Тогда Возврат "application/sparql-results+xml";
	ИначеЕсли Расширение = "sse"		Тогда Возврат "application/vnd.kodak-descriptor";
	ИначеЕсли Расширение = "ssf"		Тогда Возврат "application/vnd.epson.ssf";
	ИначеЕсли Расширение = "ssml"		Тогда Возврат "application/ssml+xml";
	ИначеЕсли Расширение = "st"			Тогда Возврат "application/vnd.sailingtracker.track";
	ИначеЕсли Расширение = "stc"		Тогда Возврат "application/vnd.sun.xml.calc.template";
	ИначеЕсли Расширение = "std"		Тогда Возврат "application/vnd.sun.xml.draw.template";
	ИначеЕсли Расширение = "stf"		Тогда Возврат "application/vnd.wt.stf";
	ИначеЕсли Расширение = "sti"		Тогда Возврат "application/vnd.sun.xml.impress.template";
	ИначеЕсли Расширение = "stk"		Тогда Возврат "application/hyperstudio";
	ИначеЕсли Расширение = "stl"		Тогда Возврат "application/vnd.ms-pki.stl";
	ИначеЕсли Расширение = "str"		Тогда Возврат "application/vnd.pg.format";
	ИначеЕсли Расширение = "stw"		Тогда Возврат "application/vnd.sun.xml.writer.template";
	ИначеЕсли Расширение = "sub"		Тогда Возврат "image/vnd.dvb.subtitle";
	ИначеЕсли Расширение = "sus"		Тогда Возврат "application/vnd.sus-calendar";
	ИначеЕсли Расширение = "sv4cpio"	Тогда Возврат "application/x-sv4cpio";
	ИначеЕсли Расширение = "sv4crc"		Тогда Возврат "application/x-sv4crc";
	ИначеЕсли Расширение = "svc"		Тогда Возврат "application/vnd.dvb.service";
	ИначеЕсли Расширение = "svd"		Тогда Возврат "application/vnd.svd";
	ИначеЕсли Расширение = "svg"		Тогда Возврат "image/svg+xml";
	ИначеЕсли Расширение = "swf"		Тогда Возврат "application/x-shockwave-flash";
	ИначеЕсли Расширение = "swi"		Тогда Возврат "application/vnd.aristanetworks.swi";
	ИначеЕсли Расширение = "sxc"		Тогда Возврат "application/vnd.sun.xml.calc";
	ИначеЕсли Расширение = "sxd"		Тогда Возврат "application/vnd.sun.xml.draw";
	ИначеЕсли Расширение = "sxg"		Тогда Возврат "application/vnd.sun.xml.writer.global";
	ИначеЕсли Расширение = "sxi"		Тогда Возврат "application/vnd.sun.xml.impress";
	ИначеЕсли Расширение = "sxm"		Тогда Возврат "application/vnd.sun.xml.math";
	ИначеЕсли Расширение = "sxw"		Тогда Возврат "application/vnd.sun.xml.writer";
	ИначеЕсли Расширение = "t"			Тогда Возврат "text/troff";
	ИначеЕсли Расширение = "tao"		Тогда Возврат "application/vnd.tao.intent-module-archive";
	ИначеЕсли Расширение = "tar"		Тогда Возврат "application/x-tar";
	ИначеЕсли Расширение = "tcap"		Тогда Возврат "application/vnd.3gpp2.tcap";
	ИначеЕсли Расширение = "tcl"		Тогда Возврат "application/x-tcl";
	ИначеЕсли Расширение = "teacher"	Тогда Возврат "application/vnd.smart.teacher";
	ИначеЕсли Расширение = "tei"		Тогда Возврат "application/tei+xml";
	ИначеЕсли Расширение = "tex"		Тогда Возврат "application/x-tex";
	ИначеЕсли Расширение = "texinfo"	Тогда Возврат "application/x-texinfo";
	ИначеЕсли Расширение = "tfi"		Тогда Возврат "application/thraud+xml";
	ИначеЕсли Расширение = "tfm"		Тогда Возврат "application/x-tex-tfm";
	ИначеЕсли Расширение = "thmx"		Тогда Возврат "application/vnd.ms-officetheme";
	ИначеЕсли Расширение = "tiff"		Тогда Возврат "image/tiff";
	ИначеЕсли Расширение = "tmo"		Тогда Возврат "application/vnd.tmobile-livetv";
	ИначеЕсли Расширение = "torrent"	Тогда Возврат "application/x-bittorrent";
	ИначеЕсли Расширение = "tpl"		Тогда Возврат "application/vnd.groove-tool-template";
	ИначеЕсли Расширение = "tpt"		Тогда Возврат "application/vnd.trid.tpt";
	ИначеЕсли Расширение = "tra"		Тогда Возврат "application/vnd.trueapp";
	ИначеЕсли Расширение = "trm"		Тогда Возврат "application/x-msterminal";
	ИначеЕсли Расширение = "tsd"		Тогда Возврат "application/timestamped-data";
	ИначеЕсли Расширение = "tsv"		Тогда Возврат "text/tab-separated-values";
	ИначеЕсли Расширение = "ttf"		Тогда Возврат "application/x-font-ttf";
	ИначеЕсли Расширение = "ttl"		Тогда Возврат "text/turtle";
	ИначеЕсли Расширение = "twd"		Тогда Возврат "application/vnd.simtech-mindmapper";
	ИначеЕсли Расширение = "txd"		Тогда Возврат "application/vnd.genomatix.tuxedo";
	ИначеЕсли Расширение = "txf"		Тогда Возврат "application/vnd.mobius.txf";
	ИначеЕсли Расширение = "txt"		Тогда Возврат "text/plain";
	ИначеЕсли Расширение = "ufd"		Тогда Возврат "application/vnd.ufdl";
	ИначеЕсли Расширение = "umj"		Тогда Возврат "application/vnd.umajin";
	ИначеЕсли Расширение = "unityweb"	Тогда Возврат "application/vnd.unity";
	ИначеЕсли Расширение = "uoml"		Тогда Возврат "application/vnd.uoml+xml";
	ИначеЕсли Расширение = "uri"		Тогда Возврат "text/uri-list";
	ИначеЕсли Расширение = "ustar"		Тогда Возврат "application/x-ustar";
	ИначеЕсли Расширение = "utz"		Тогда Возврат "application/vnd.uiq.theme";
	ИначеЕсли Расширение = "uu"			Тогда Возврат "text/x-uuencode";
	ИначеЕсли Расширение = "uva"		Тогда Возврат "audio/vnd.dece.audio";
	ИначеЕсли Расширение = "uvh"		Тогда Возврат "video/vnd.dece.hd";
	ИначеЕсли Расширение = "uvi"		Тогда Возврат "image/vnd.dece.graphic";
	ИначеЕсли Расширение = "uvm"		Тогда Возврат "video/vnd.dece.mobile";
	ИначеЕсли Расширение = "uvp"		Тогда Возврат "video/vnd.dece.pd";
	ИначеЕсли Расширение = "uvs"		Тогда Возврат "video/vnd.dece.sd";
	ИначеЕсли Расширение = "uvu"		Тогда Возврат "video/vnd.uvvu.mp4";
	ИначеЕсли Расширение = "uvv"		Тогда Возврат "video/vnd.dece.video";
	ИначеЕсли Расширение = "vcd"		Тогда Возврат "application/x-cdlink";
	ИначеЕсли Расширение = "vcf"		Тогда Возврат "text/x-vcard";
	ИначеЕсли Расширение = "vcg"		Тогда Возврат "application/vnd.groove-vcard";
	ИначеЕсли Расширение = "vcs"		Тогда Возврат "text/x-vcalendar";
	ИначеЕсли Расширение = "vcx"		Тогда Возврат "application/vnd.vcx";
	ИначеЕсли Расширение = "vis"		Тогда Возврат "application/vnd.visionary";
	ИначеЕсли Расширение = "viv"		Тогда Возврат "video/vnd.vivo";
	ИначеЕсли Расширение = "vsd"		Тогда Возврат "application/vnd.visio";
	ИначеЕсли Расширение = "vsdx"		Тогда Возврат "application/vnd.visio2013";
	ИначеЕсли Расширение = "vsf"		Тогда Возврат "application/vnd.vsf";
	ИначеЕсли Расширение = "vtu"		Тогда Возврат "model/vnd.vtu";
	ИначеЕсли Расширение = "vxml"		Тогда Возврат "application/voicexml+xml";
	ИначеЕсли Расширение = "wad"		Тогда Возврат "application/x-doom";
	ИначеЕсли Расширение = "wav"		Тогда Возврат "audio/x-wav";
	ИначеЕсли Расширение = "wax"		Тогда Возврат "audio/x-ms-wax";
	ИначеЕсли Расширение = "wbmp"		Тогда Возврат "image/vnd.wap.wbmp";
	ИначеЕсли Расширение = "wbs"		Тогда Возврат "application/vnd.criticaltools.wbs+xml";
	ИначеЕсли Расширение = "wbxml"		Тогда Возврат "application/vnd.wap.wbxml";
	ИначеЕсли Расширение = "weba"		Тогда Возврат "audio/webm";
	ИначеЕсли Расширение = "webm"		Тогда Возврат "video/webm";
	ИначеЕсли Расширение = "webp"		Тогда Возврат "image/webp";
	ИначеЕсли Расширение = "wg"			Тогда Возврат "application/vnd.pmi.widget";
	ИначеЕсли Расширение = "wgt"		Тогда Возврат "application/widget";
	ИначеЕсли Расширение = "wm"			Тогда Возврат "video/x-ms-wm";
	ИначеЕсли Расширение = "wma"		Тогда Возврат "audio/x-ms-wma";
	ИначеЕсли Расширение = "wmd"		Тогда Возврат "application/x-ms-wmd";
	ИначеЕсли Расширение = "wmf"		Тогда Возврат "application/x-msmetafile";
	ИначеЕсли Расширение = "wml"		Тогда Возврат "text/vnd.wap.wml";
	ИначеЕсли Расширение = "wmlc"		Тогда Возврат "application/vnd.wap.wmlc";
	ИначеЕсли Расширение = "wmls"		Тогда Возврат "text/vnd.wap.wmlscript";
	ИначеЕсли Расширение = "wmlsc"		Тогда Возврат "application/vnd.wap.wmlscriptc";
	ИначеЕсли Расширение = "wmv"		Тогда Возврат "video/x-ms-wmv";
	ИначеЕсли Расширение = "wmx"		Тогда Возврат "video/x-ms-wmx";
	ИначеЕсли Расширение = "wmz"		Тогда Возврат "application/x-ms-wmz";
	ИначеЕсли Расширение = "woff"		Тогда Возврат "application/x-font-woff";
	ИначеЕсли Расширение = "wpd"		Тогда Возврат "application/vnd.wordperfect";
	ИначеЕсли Расширение = "wpl"		Тогда Возврат "application/vnd.ms-wpl";
	ИначеЕсли Расширение = "wps"		Тогда Возврат "application/vnd.ms-works";
	ИначеЕсли Расширение = "wqd"		Тогда Возврат "application/vnd.wqd";
	ИначеЕсли Расширение = "wri"		Тогда Возврат "application/x-mswrite";
	ИначеЕсли Расширение = "wrl"		Тогда Возврат "model/vrml";
	ИначеЕсли Расширение = "wsdl"		Тогда Возврат "application/wsdl+xml";
	ИначеЕсли Расширение = "wspolicy"	Тогда Возврат "application/wspolicy+xml";
	ИначеЕсли Расширение = "wtb"		Тогда Возврат "application/vnd.webturbo";
	ИначеЕсли Расширение = "wvx"		Тогда Возврат "video/x-ms-wvx";
	ИначеЕсли Расширение = "x3d"		Тогда Возврат "application/vnd.hzn-3d-crossword";
	ИначеЕсли Расширение = "xap"		Тогда Возврат "application/x-silverlight-app";
	ИначеЕсли Расширение = "xar"		Тогда Возврат "application/vnd.xara";
	ИначеЕсли Расширение = "xbap"		Тогда Возврат "application/x-ms-xbap";
	ИначеЕсли Расширение = "xbd"		Тогда Возврат "application/vnd.fujixerox.docuworks.binder";
	ИначеЕсли Расширение = "xbm"		Тогда Возврат "image/x-xbitmap";
	ИначеЕсли Расширение = "xdf"		Тогда Возврат "application/xcap-diff+xml";
	ИначеЕсли Расширение = "xdm"		Тогда Возврат "application/vnd.syncml.dm+xml";
	ИначеЕсли Расширение = "xdp"		Тогда Возврат "application/vnd.adobe.xdp+xml";
	ИначеЕсли Расширение = "xdssc"		Тогда Возврат "application/dssc+xml";
	ИначеЕсли Расширение = "xdw"		Тогда Возврат "application/vnd.fujixerox.docuworks";
	ИначеЕсли Расширение = "xenc"		Тогда Возврат "application/xenc+xml";
	ИначеЕсли Расширение = "xer"		Тогда Возврат "application/patch-ops-error+xml";
	ИначеЕсли Расширение = "xfdf"		Тогда Возврат "application/vnd.adobe.xfdf";
	ИначеЕсли Расширение = "xfdl"		Тогда Возврат "application/vnd.xfdl";
	ИначеЕсли Расширение = "xhtml"		Тогда Возврат "application/xhtml+xml";
	ИначеЕсли Расширение = "xif"		Тогда Возврат "image/vnd.xiff";
	ИначеЕсли Расширение = "xlam"		Тогда Возврат "application/vnd.ms-excel.addin.macroenabled.12";
	ИначеЕсли Расширение = "xls"		Тогда Возврат "application/vnd.ms-excel";
	ИначеЕсли Расширение = "xlsb"		Тогда Возврат "application/vnd.ms-excel.sheet.binary.macroenabled.12";
	ИначеЕсли Расширение = "xlsm"		Тогда Возврат "application/vnd.ms-excel.sheet.macroenabled.12";
	ИначеЕсли Расширение = "xlsx"		Тогда Возврат "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
	ИначеЕсли Расширение = "xltm"		Тогда Возврат "application/vnd.ms-excel.template.macroenabled.12";
	ИначеЕсли Расширение = "xltx"		Тогда Возврат "application/vnd.openxmlformats-officedocument.spreadsheetml.template";
	ИначеЕсли Расширение = "xml"		Тогда Возврат "application/xml";
	ИначеЕсли Расширение = "xo"			Тогда Возврат "application/vnd.olpc-sugar";
	ИначеЕсли Расширение = "xop"		Тогда Возврат "application/xop+xml";
	ИначеЕсли Расширение = "xpi"		Тогда Возврат "application/x-xpinstall";
	ИначеЕсли Расширение = "xpm"		Тогда Возврат "image/x-xpixmap";
	ИначеЕсли Расширение = "xpr"		Тогда Возврат "application/vnd.is-xpr";
	ИначеЕсли Расширение = "xps"		Тогда Возврат "application/vnd.ms-xpsdocument";
	ИначеЕсли Расширение = "xpw"		Тогда Возврат "application/vnd.intercon.formnet";
	ИначеЕсли Расширение = "xslt"		Тогда Возврат "application/xslt+xml";
	ИначеЕсли Расширение = "xsm"		Тогда Возврат "application/vnd.syncml+xml";
	ИначеЕсли Расширение = "xspf"		Тогда Возврат "application/xspf+xml";
	ИначеЕсли Расширение = "xul"		Тогда Возврат "application/vnd.mozilla.xul+xml";
	ИначеЕсли Расширение = "xwd"		Тогда Возврат "image/x-xwindowdump";
	ИначеЕсли Расширение = "xyz"		Тогда Возврат "chemical/x-xyz";
	ИначеЕсли Расширение = "yaml"		Тогда Возврат "text/yaml";
	ИначеЕсли Расширение = "yang"		Тогда Возврат "application/yang";
	ИначеЕсли Расширение = "yin"		Тогда Возврат "application/yin+xml";
	ИначеЕсли Расширение = "zaz"		Тогда Возврат "application/vnd.zzazz.deck+xml";
	ИначеЕсли Расширение = "zip"		Тогда Возврат "application/zip";
	ИначеЕсли Расширение = "zir"		Тогда Возврат "application/vnd.zul";
	ИначеЕсли Расширение = "zmm"		Тогда Возврат "application/vnd.handheld-entertainment+xml";
	КонецЕсли;
	
	Возврат Неопределено;

КонецФункции

Функция РазобратьСоставноеТело(HTTPОбъект) Экспорт
	
	Заголовки 	= HTTPОбъект.Заголовки;
	Тело 		= HTTPОбъект.ПолучитьТелоКакПоток();
	
	СоставноеТело = Новый Структура;
	СоставноеТело.Вставить("Преамбула");
	СоставноеТело.Вставить("СоставныеЧасти", Новый Массив);
	СоставноеТело.Вставить("Эпилог");
	СоставноеТело.Вставить("ТекстОшибки", "");
	
	СвойстваЗаголовка = ПолучитьСвойстваЗаголовка(, Заголовки, "Content-Type");
	Разделитель = СвойстваЗаголовка.Получить("boundary");
	Если НЕ ЗначениеЗаполнено(Разделитель) Тогда
		СоставноеТело.ТекстОшибки = НСтр("ru = 'Не найден разделитель (boundary)!'");
		Возврат СоставноеТело;
	КонецЕсли;
	
	Кодировка = СвойстваЗаголовка.Получить("charset");
	
	РазделительСтрок = ПодобратьРазделительСтрокСоставногоТела(Тело, Кодировка, Разделитель);
	Если РазделительСтрок = Неопределено Тогда
		СоставноеТело.ТекстОшибки = НСтр("ru = 'Неправильно сформированное сообщение'");
		Возврат СоставноеТело;
	КонецЕсли;
	
	Маркеры = Новый Массив;
	Маркеры.Добавить(РазделительСтрок + "--" + Разделитель + РазделительСтрок);
	Маркеры.Добавить(РазделительСтрок + "--" + Разделитель + "--" + РазделительСтрок);
	
	МаркерПреамбулы = "--" + Разделитель + РазделительСтрок;
	
	ЧтениеДанных = Новый ЧтениеДанных(Тело, Кодировка);
	Преамбула = ЧтениеДанных.ПрочитатьДо(МаркерПреамбулы);
	Если Не Преамбула.МаркерНайден Тогда
		СоставноеТело.ТекстОшибки = НСтр("ru = 'Неправильно сформированное сообщение'");
		Возврат СоставноеТело;
	КонецЕсли;
	
	СоставноеТело.Преамбула = Преамбула.ПолучитьДвоичныеДанные();
	
	СоставныеЧасти = Новый Массив;

	Пока Истина Цикл
		
		Часть = ЧтениеДанных.ПрочитатьДо(Маркеры);
		Если Не Часть.МаркерНайден Тогда
			Прервать;
		КонецЕсли;
		
		ЧтениеЧасти = Новый ЧтениеДанных(Часть.ОткрытьПотокДляЧтения());
		ЗаголовкиЧасти = ПрочитатьЗаголовки(ЧтениеЧасти);
		
		Расположение = ПолучитьСвойстваЗаголовка(, ЗаголовкиЧасти, "Content-Disposition");
		ТипКонтента = СвойствоСоответствия(ЗаголовкиЧасти, "Content-Type");
		
		ИмяФайла = Расположение.Получить("filename");
		Если Расположение.Получить("filename*") <> Неопределено Тогда
			СтрокаИмяФайла = СтрРазделить(Расположение.Получить("filename*"), "''");
			Если СтрокаИмяФайла.Количество() = 2 Тогда
				КодировкаСтроки = НРег(СтрокаИмяФайла[0]);
				ИмяФайла = РаскодироватьСтроку(СтрокаИмяФайла[1], СпособКодированияСтроки.КодировкаURL, КодировкаСтроки);
			КонецЕсли;
		КонецЕсли;
		
		СоставныеЧасти.Добавить(HTTPСервисы.СтруктураОписаниеДанных(Расположение.Получить("Значение"),
																		  Расположение.Получить("name"),
																		  ЧтениеЧасти.Прочитать().ПолучитьДвоичныеДанные(),
																		  ИмяФайла,
																		  ТипКонтента));
		
		ЧтениеЧасти.Закрыть();
		
	КонецЦикла;
	
	СоставноеТело.СоставныеЧасти = ОбщегоНазначения.СкопироватьРекурсивно(СоставныеЧасти);
	СоставноеТело.Эпилог = Часть.ПолучитьДвоичныеДанные();	
	
	ЧтениеДанных.Закрыть();
	
	Возврат СоставноеТело;
	
КонецФункции

Функция ПодобратьРазделительСтрокСоставногоТела(Тело, Кодировка, Разделитель)
	
	Буфер = Новый БуферДвоичныхДанных(200);
	Тело.Прочитать(Буфер, 0, 200);
	Тело.Перейти(0, ПозицияВПотоке.Начало);
	
	ДвоичныеДанные = ПолучитьДвоичныеДанныеИзБуфераДвоичныхДанных(Буфер);
	
	РазделительСтрок = Символы.ВК + Символы.ПС;
	
	МаркерПреамбулы = "--" + Разделитель + РазделительСтрок;
	
	ЧтениеДанных = Новый ЧтениеДанных(ДвоичныеДанные.ОткрытьПотокДляЧтения(), Кодировка);
	
	Преамбула = ЧтениеДанных.ПрочитатьДо(МаркерПреамбулы);
	
	Если Не Преамбула.МаркерНайден Тогда
		
		РазделительСтрок = Символы.ПС;
		
		МаркерПреамбулы = "--" + Разделитель + РазделительСтрок;
		
		ЧтениеДанных = Новый ЧтениеДанных(ДвоичныеДанные.ОткрытьПотокДляЧтения(), Кодировка);
		
		Преамбула = ЧтениеДанных.ПрочитатьДо(МаркерПреамбулы);
		
	КонецЕсли;
	
	Если Не Преамбула.МаркерНайден Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат РазделительСтрок;
	
КонецФункции

// Разбирает multipart/form-data согласно https://tools.ietf.org/html/rfc7578
// 
Функция РазобратьСоставноеТелоТекст(HTTPОбъект) Экспорт
	
	Заголовки 	= HTTPОбъект.Заголовки;
	ТелоСтрокой = HTTPОбъект.ПолучитьТелоКакСтроку();
	
	СоставноеТело = Новый Структура;
	СоставноеТело.Вставить("СоставныеЧасти", Новый Массив);
	СоставноеТело.Вставить("ТекстОшибки", "");
	
	СвойстваЗаголовка = ПолучитьСвойстваЗаголовка(, Заголовки, "Content-Type");
	Разделитель = СвойстваЗаголовка.Получить("boundary");
	Если НЕ ЗначениеЗаполнено(Разделитель) Тогда
		СоставноеТело.ТекстОшибки = НСтр("ru = 'Не найден разделитель (boundary)!'");
		Возврат СоставноеТело;
	КонецЕсли;
	
	СоставныеЧасти = Новый Массив;
	
	Кодировка = СвойстваЗаголовка.Получить("charset");
	Если Кодировка = Неопределено Тогда
		Кодировка = "UTF-8";
	КонецЕсли;
	
	КонечныйМаркер = СтрШаблон("%2--%1--%2", Разделитель, Символы.ПС);
	
	ПозицияКонечногоМаркера = СтрНайти(ТелоСтрокой, КонечныйМаркер, НаправлениеПоиска.СКонца);
	Если ПозицияКонечногоМаркера = 0 Тогда
		СоставноеТело.ТекстОшибки = НСтр("ru = 'Не найден конечный разделитель (--boundary--)!'");
		Возврат СоставноеТело;
	КонецЕсли;
	
	ДлинаСтроки = ПозицияКонечногоМаркера - 1;
	
	Тело = ПолучитьДвоичныеДанныеИзСтроки(Лев(ТелоСтрокой, ДлинаСтроки)).ОткрытьПотокДляЧтения();
	
	РазделительСтрок 	= СтрШаблон("%2--%1%2", Разделитель, Символы.ПС);
	МаркерПреамбулы 	= СтрШаблон("--%1%2", Разделитель, Символы.ПС);
	
	ЧтениеТекста = Новый ЧтениеТекста(Тело, Кодировка, РазделительСтрок);
	ЧтениеТекста.ПрочитатьСтроку(МаркерПреамбулы);
	
	Пока Истина Цикл
		
		Часть = ЧтениеТекста.ПрочитатьСтроку();
		
		Если Часть = Неопределено Тогда
			Прервать;
		КонецЕсли;
		
		Поток = ПолучитьДвоичныеДанныеИзСтроки(Часть).ОткрытьПотокДляЧтения();
		
		ЧтениеЧасти = Новый ЧтениеТекста(Поток, Кодировка);
		
		ЗаголовкиЧасти = ПрочитатьЗаголовки(ЧтениеЧасти);

		Расположение = ПолучитьСвойстваЗаголовка(, ЗаголовкиЧасти, "Content-Disposition");
		
		ТипКонтента = СвойствоСоответствия(ЗаголовкиЧасти, "Content-Type");
		Если ТипКонтента = Неопределено Тогда
			ТипКонтента = "text/plain";
		КонецЕсли;
		
		ИмяФайла = Расположение.Получить("filename");
		Если Расположение.Получить("filename*") <> Неопределено Тогда
			СтрокаИмяФайла = СтрРазделить(Расположение.Получить("filename*"), "''");
			Если СтрокаИмяФайла.Количество() = 2 Тогда
				КодировкаСтроки = НРег(СтрокаИмяФайла[0]);
				ИмяФайла = РаскодироватьСтроку(СтрокаИмяФайла[1], СпособКодированияСтроки.КодировкаURL, КодировкаСтроки);
			КонецЕсли;
		КонецЕсли;
		
		Данные = ЧтениеЧасти.Прочитать();
		Если ТипКонтента <> "text/plain" Тогда
			
			Поток = Новый ПотокВПамяти;
			ЗаписьДанных = Новый ЗаписьДанных(Поток, Кодировка);
			ЗаписьДанных.ЗаписатьСимволы(Данные, Кодировка);
			ЗаписьДанных.Закрыть();
			
			Данные = Поток.ЗакрытьИПолучитьДвоичныеДанные();
			//ПолучитьДвоичныеДанныеИзСтроки(Данные, Кодировка);
		КонецЕсли;
		
		ЧтениеЧасти.Закрыть();
		
		СоставныеЧасти.Добавить(HTTPСервисы.СтруктураОписаниеДанных(Расположение.Получить("Значение"),
																		  Расположение.Получить("name"),
																		  Данные,
																		  ИмяФайла,
																		  ТипКонтента));
		
	КонецЦикла;
	
	СоставноеТело.СоставныеЧасти = ОбщегоНазначения.СкопироватьРекурсивно(СоставныеЧасти);
	
	ЧтениеТекста.Закрыть();
	
 	Возврат СоставноеТело;
	
КонецФункции

Функция ПредставлениеОбъектаHTTP(HTTPОбъект) Экспорт
	
	Представление = "";
	Если ТипЗнч(HTTPОбъект) = Тип("HTTPЗапрос") Тогда 
		
		ПредставлениеТела = ПредставлениеТелаHTTPОбъекта(HTTPОбъект);
		
		Шаблон = НСтр("ru = 'HTTP Запрос:
	       					|Адрес: %1
	       					|Заголовки:
							|%2
							|
							|Тело:
							|%3'");
		Представление = СтрШаблон(Шаблон,
						HTTPОбъект.АдресРесурса,
						ПредставлениеЗаголовковHTTP(HTTPОбъект.Заголовки),
						ПредставлениеТела);
						
	ИначеЕсли ТипЗнч(HTTPОбъект) = Тип("HTTPОтвет") Тогда
		
		ПредставлениеТела = ПредставлениеТелаHTTPОбъекта(HTTPОбъект);
		
		Шаблон = НСтр("ru = 'HTTP Запрос:
	       					|Код: %1
	       					|Заголовки:
							|%2
							|
							|Тело:
							|%3'");
		Представление = СтрШаблон(Шаблон,
						"" + HTTPОбъект.КодСостояния + " " + КодСостоянияПояснение(HTTPОбъект.КодСостояния),
						ПредставлениеЗаголовковHTTP(HTTPОбъект.Заголовки),
						ПредставлениеТела);
						
	КонецЕсли;
	
	Возврат Представление;
	
КонецФункции

Функция ЧастьСоставныхДанных(ОписаниеДанных) Экспорт
	
	СтрокаРасположение = СтрШаблон("Content-Disposition: %1", ЗаголовокContentDisposition(ОписаниеДанных));
	
	Поток = Новый ПотокВПамяти;
	ЗаписьДанных = Новый ЗаписьДанных(Поток);
	ЗаписьДанных.ЗаписатьСтроку(СтрокаРасположение);
	
	Если ЗначениеЗаполнено(ОписаниеДанных.ТипКонтента) Тогда
		ЗаписьДанных.ЗаписатьСтроку(СтрШаблон("Content-Type: %1", ОписаниеДанных.ТипКонтента));
	КонецЕсли;
	
	ДвоичныеДанные = ПолучитьДвоичныеДанные(ОписаниеДанных.Данные);
	
	ЗаписьДанных.ЗаписатьСтроку("");
	
	Если ТипЗнч(ДвоичныеДанные) = Тип("ДвоичныеДанные") Тогда
		ЗаписьДанных.Записать(ДвоичныеДанные);
		ЗаписьДанных.ЗаписатьСимволы(Символы.ПС);
	Иначе
		ЗаписьДанных.ЗаписатьСтроку(ДвоичныеДанные);
	КонецЕсли;
	
	ЗаписьДанных.Закрыть();
	
	Возврат Поток.ЗакрытьИПолучитьДвоичныеДанные();
	
КонецФункции

Функция ЗаголовокContentDisposition(ОписаниеДанных)
	
	МассивРасположение = Новый Массив;
	МассивРасположение.Добавить(ОписаниеДанных.Расположение);
	
	Если ЗначениеЗаполнено(ОписаниеДанных.Наименование) Тогда
		МассивРасположение.Добавить(СтрШаблон("; name=""%1""", ОписаниеДанных.Наименование));
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОписаниеДанных.ИмяФайла) Тогда
		МассивРасположение.Добавить(СтрШаблон("; filename=""%1""", СокрЛП(ОписаниеДанных.ИмяФайла)));
		// Необходимо учесть особенности кодировки в заголовке Content-Disposition в разных браузерах
		// https://greenbytes.de/tech/webdav/rfc6266.html
		ИмяФайлаВКодировке = СокрЛП(КодироватьСтроку(ОписаниеДанных.ИмяФайла, СпособКодированияСтроки.КодировкаURL, КодировкаТекста.UTF8));
		МассивРасположение.Добавить(СтрШаблон("; filename*=UTF-8''%1", ИмяФайлаВКодировке));
	КонецЕсли;
	
	Возврат СтрСоединить(МассивРасположение, "");

КонецФункции

Функция ПолучитьДвоичныеДанные(Данные)
	
	Если ТипЗнч(Данные) = Тип("ДвоичныеДанные") Тогда
		Возврат Данные;
	ИначеЕсли ТипЗнч(Данные) = Тип("Строка") Тогда
		
		Если ЭтоАдресВременногоХранилища(Данные) Тогда
			Возврат ПолучитьДвоичныеДанные(ПолучитьИзВременногоХранилища(Данные));
		КонецЕсли;
		
		Файл = Новый Файл(Данные);
		Если Файл.Существует() Тогда
			Возврат Новый ДвоичныеДанные(Данные);
		КонецЕсли;
		
		Возврат Данные;
		
	ИначеЕсли ТипЗнч(Данные) = Тип("Число") ИЛИ ТипЗнч(Данные) = Тип("Булево") Тогда
		Возврат Формат(Данные, "ЧН=0; ЧГ=0; БЛ=false; БИ=true");
	ИначеЕсли ТипЗнч(Данные) = Тип("Дата") Тогда
		Возврат Формат(Данные, "ДФ=yyyy-MM-ddTHH:mm:ss");
	ИначеЕсли Данные = Неопределено Тогда
		Возврат "null";
	КонецЕсли;
	
	Возврат Строка(Данные);
	
КонецФункции

Процедура УстановитьТелоИЗаголовки(HTTPОбъект, Тело, Файл, Заголовки, ТипКонтента, Кодировка) Экспорт
	
	HTTPОбъект.Заголовки.Вставить("Cache-Control", "no-cache");
	
	Если Файл <> "" Тогда
		
		ЧтениеДанных = Неопределено;
		
		Если ТипЗнч(Файл) = Тип("ДвоичныеДанные") Тогда
			HTTPОбъект.УстановитьТелоИзДвоичныхДанных(Файл);
		ИначеЕсли ТипЗнч(Файл) = Тип("Строка") Тогда
			
			Если ЭтоАдресВременногоХранилища(Файл) Тогда
				УстановитьТелоИЗаголовки(HTTPОбъект, Тело, ПолучитьИзВременногоХранилища(Файл), Заголовки, ТипКонтента, Кодировка);
				Возврат;
			КонецЕсли;
			
			ФайлНаДиске = Новый Файл(Файл);
			Если НЕ ФайлНаДиске.Существует() Тогда
				ТекстОшибки = НСтр("ru = 'Не найден файл: '") + Файл;
				ЗаписатьОшибкуВЖурналРегистрации("Установить тело и заголовки",, ТекстОшибки);
				ВызватьИсключение НСтр("ru = 'Не найден файл'");
			КонецЕсли;
			
			HTTPОбъект.УстановитьИмяФайлаТела(Файл);
			
		ИначеЕсли ТипЗнч(Файл) = Тип("Поток") ИЛИ 
			 ТипЗнч(Файл) = Тип("ПотокВПамяти") ИЛИ 
			 ТипЗнч(Файл) = Тип("ФайловыйПоток") Тогда
			 
			ЧтениеДанных = Новый ЧтениеДанных(Файл);
			
		ИначеЕсли ТипЗнч(Файл) = Тип("ЧтениеДанных") Тогда
			ЧтениеДанных = Файл;
		ИначеЕсли ТипЗнч(Файл) = Тип("Структура") Тогда
			
			ОписаниеДанных = Файл;
			
			Если Заголовки = Неопределено Тогда
				Заголовки = Новый Соответствие;
			КонецЕсли;
			
			Заголовки.Вставить("Content-Disposition", 	ЗаголовокContentDisposition(ОписаниеДанных));
			Заголовки.Вставить("Content-Type", 			ОписаниеДанных.ТипКонтента);
			
			УстановитьТелоИЗаголовки(HTTPОбъект, Тело, ОписаниеДанных.Данные, Заголовки, ТипКонтента, Кодировка);
			Возврат;
			
		Иначе
			ВызватьИсключение СтрШаблон(НСтр("ru = 'Неверный формат файла: %1'"), ТипЗнч(Файл));
		КонецЕсли;
		
		Если ЧтениеДанных <> Неопределено Тогда
			
			ПотокТела = HTTPОбъект.ПолучитьТелоКакПоток();
			ЧтениеДанных.КопироватьВ(ПотокТела);
			ЧтениеДанных.Закрыть();
			HTTPОбъект.Заголовки.Вставить("Content-Length", Формат(ПотокТела.Размер(), "ЧГ=0"));
			
			ПотокТела.Закрыть();
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ТипКонтента) И НЕ ЗначениеЗаполнено(HTTPОбъект.Заголовки["Content-Type"]) Тогда
			HTTPОбъект.Заголовки.Вставить("Content-Type", ТипКонтента);
		КонецЕсли;
		
	ИначеЕсли Тело <> "" Тогда
		
		Если ТипЗнч(Тело) = Тип("ДвоичныеДанные") ИЛИ
			 ТипЗнч(Тело) = Тип("Поток") ИЛИ 
			 ТипЗнч(Тело) = Тип("ПотокВПамяти") ИЛИ 
			 ТипЗнч(Тело) = Тип("ФайловыйПоток") ИЛИ 
			 ТипЗнч(Тело) = Тип("ЧтениеДанных") Тогда
			УстановитьТелоИЗаголовки(HTTPОбъект, Файл, Тело, Заголовки, ТипКонтента, Кодировка);
			Возврат;
		КонецЕсли;
		
		СтрокаОтвета = Тело;
		
		Если ТипКонтента = "application/json" Тогда
			
			Если ТипЗнч(СтрокаОтвета) = Тип("Строка") Тогда
				
				СтруктураОтвета = Новый Структура;
				Если ТипЗнч(HTTPОбъект) <> Тип("HTTPСервисОтвет") Тогда
					СтруктураОтвета.Вставить("result", СтрокаОтвета);
				ИначеЕсли HTTPОбъект.КодСостояния = 200 Тогда
					СтруктураОтвета.Вставить("result", СтрокаОтвета);
				Иначе
					СтруктураОтвета.Вставить("error", СтрокаОтвета);
				КонецЕсли;
				
				СтрокаОтвета = СтруктураОтвета;
				
			КонецЕсли;
			
			СтрокаОтвета = HTTPСервисы.ЗначениеВJSON(СтрокаОтвета,, Истина);
			
		ИначеЕсли ТипКонтента = "application/x-www-form-urlencoded" Тогда
			
			Если ТипЗнч(СтрокаОтвета) = Тип("Строка") Тогда
				Если СтрокаОтвета = РаскодироватьСтроку(СтрокаОтвета, СпособКодированияСтроки.КодировкаURL, Кодировка) Тогда
					СтрокаОтвета = КодироватьСтроку(СтрокаОтвета, СпособКодированияСтроки.КодировкаURL, Кодировка);
				КонецЕсли;
			ИначеЕсли ТипЗнч(СтрокаОтвета) = Тип("Структура") ИЛИ
					ТипЗнч(СтрокаОтвета) = Тип("ФиксированнаяСтруктура") ИЛИ
					ТипЗнч(СтрокаОтвета) = Тип("Соответствие") ИЛИ
					ТипЗнч(СтрокаОтвета) = Тип("ФиксированноеСоответствие") Тогда
				СтрокаОтвета = HTTPСервисы.КодироватьКоллекциюВДанныеФормы(СтрокаОтвета);
			КонецЕсли;
			
		КонецЕсли;
		
		Если ТипЗнч(СтрокаОтвета) <> Тип("Строка") Тогда
			ВызватьИсключение СтрШаблон(НСтр("ru = 'Неверный формат тела: %1'"), ТипЗнч(СтрокаОтвета));
		КонецЕсли;
		
		HTTPОбъект.Заголовки.Вставить("Content-Type", СтрШаблон("%1;charset=%2", ТипКонтента, НРег(Кодировка)));
		HTTPОбъект.УстановитьТелоИзСтроки(СтрокаОтвета, Кодировка, ИспользованиеByteOrderMark.НеИспользовать);
		
	КонецЕсли;
	
	Если HTTPОбъект.Заголовки["Content-Length"] = Неопределено Тогда
		ТелоПоток = HTTPОбъект.ПолучитьТелоКакПоток();
		Если ТелоПоток.ДоступноИзменениеПозиции Тогда
			HTTPОбъект.Заголовки.Вставить("Content-Length", Формат(ТелоПоток.Размер(), "ЧГ=0"));
		КонецЕсли;
	КонецЕсли;
	
	Если ТипЗнч(Заголовки) = Тип("Соответствие") Тогда
		ОбщегоНазначенияКлиентСервер.ДополнитьСоответствие(HTTPОбъект.Заголовки, Заголовки, Истина);
	КонецЕсли;
	
КонецПроцедуры

// Записывает событие в журнал регистрации с префиксом
//
// Параметры:
//  ИмяСобытия  - Строка - Имя события для записи в журнал
//  ЭтоОшибка  - Булево - Если Истина, уровень журнала - Ошибка, иначе Информация
//  Данные  - Строка - Данные записи журнала
//  Комментарий  - Строка - Комментарий записи журнала
//
Процедура ЗаписатьОшибкуВЖурналРегистрации(ИмяСобытия, Данные, Комментарий) Экспорт
	
	ИмяСобытияБазовое = НСтр("ru = 'АРБИС.HTTPСервисы.'");
	ЗаписьЖурналаРегистрации(ИмяСобытияБазовое + ИмяСобытия,
							 УровеньЖурналаРегистрации.Ошибка,,
							 Данные,
							 Комментарий);
							 
КонецПроцедуры

Функция СвойствоСоответствия(Соответствие, ИмяСвойства) Экспорт
	
	Заголовок = Соответствие.Получить(ИмяСвойства);
	Если Заголовок <> Неопределено Тогда
		Возврат Заголовок;
	КонецЕсли;
	
	Заголовок = Соответствие.Получить(НРег(ИмяСвойства));
	Если Заголовок <> Неопределено Тогда
		Возврат Заголовок;
	КонецЕсли;
	
	Заголовок = Соответствие.Получить(ВРег(ИмяСвойства));
	Если Заголовок <> Неопределено Тогда
		Возврат Заголовок;
	КонецЕсли;
	
	Для Каждого ЗаголовокОбъект Из Соответствие Цикл
		Если СтрСравнить(ЗаголовокОбъект.Ключ, ИмяСвойства) = 0 Тогда
			Возврат ЗаголовокОбъект.Значение;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьСвойстваЗаголовка(ЗначениеЗаголовка = "", Заголовки = Неопределено, ИмяЗаголовка = "")
	
	СвойстваЗаголовка = Новый Соответствие;
	СвойстваЗаголовка.Вставить("Значение");
	
	Если НЕ ЗначениеЗаполнено(ЗначениеЗаголовка) Тогда
		ЗначениеЗаголовка = СвойствоСоответствия(Заголовки, ИмяЗаголовка);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ЗначениеЗаголовка) Тогда
		Возврат СвойстваЗаголовка;
	КонецЕсли;
	
	Свойства = СтрРазделить(ЗначениеЗаголовка, ";", Ложь);
	Если Свойства.Количество() = 0 Тогда
		Возврат СвойстваЗаголовка;
	КонецЕсли;
	
	СвойстваЗаголовка.Вставить("Значение", СокрЛП(Свойства[0]));
	Свойства.Удалить(0);
	
	Для Каждого Свойство Из Свойства Цикл
		
		ПозицияРазделителя = СтрНайти(Свойство, "=");
		Если ПозицияРазделителя = 0 Тогда
			СвойстваЗаголовка.Вставить(НРег(СокрЛП(Свойство)));
			Продолжить;
		КонецЕсли;
		
		ИмяСвойства = НРег(СокрЛП(Сред(Свойство, 1, ПозицияРазделителя - 1)));
		
		ЗначениеСвойства = Сред(Свойство, ПозицияРазделителя + 1);
		
		Если СтрНачинаетсяС(ЗначениеСвойства, """") И СтрЗаканчиваетсяНа(ЗначениеСвойства, """") Тогда
			ЗначениеСвойства = Лев(ЗначениеСвойства, СтрДлина(ЗначениеСвойства) - 1);
			ЗначениеСвойства = Прав(ЗначениеСвойства, СтрДлина(ЗначениеСвойства) - 1);
		КонецЕсли;
		
		Если СтрНачинаетсяС(ЗначениеСвойства, "=?") И СтрЗаканчиваетсяНа(ЗначениеСвойства, "?=") Тогда
			
			// http://www.faqs.org/rfcs/rfc2047.html
			
			ЗначениеСвойства = Лев(ЗначениеСвойства, СтрДлина(ЗначениеСвойства) - 2);
			ЗначениеСвойства = Прав(ЗначениеСвойства, СтрДлина(ЗначениеСвойства) - 2);
			
			Части = СтрРазделить(ЗначениеСвойства, "?");
			Если Части.Количество() = 3 Тогда
				
				Кодировка 	= Части[0];
				ВидКода 	= Части[1];
				Значение 	= Части[2];
				
				Если НРег(ВидКода) = "b" Тогда
					ЗначениеСвойства = ПолучитьСтрокуИзДвоичныхДанных(Base64Значение(Значение), Кодировка);
				ИначеЕсли НРег(ВидКода) = "q" Тогда
					ЗначениеСвойства = РаскодироватьQuotedPrintable(Значение, Кодировка);
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
		СвойстваЗаголовка.Вставить(ИмяСвойства, ЗначениеСвойства);
		
	КонецЦикла;
	
	Возврат СвойстваЗаголовка;
	
КонецФункции

Функция ПрочитатьЗаголовки(ЧтениеДанных)
	
	Заголовки = Новый Соответствие;
	
	Пока Истина Цикл
		Стр = ЧтениеДанных.ПрочитатьСтроку();
		
		Если Стр = "" Тогда
			Прервать;
		КонецЕсли;
		
		Части = СтрРазделить(Стр, ":");
		ИмяЗаголовка = СокрЛП(Части[0]);
		Значение = СокрЛП(Части[1]);
		
		Заголовки.Вставить(ИмяЗаголовка, Значение);
		
	КонецЦикла;
	
	Возврат Заголовки;
	
КонецФункции

Функция ПредставлениеЗаголовковHTTP(Заголовки)
	
	ПредставлениеЗаголовков = Новый Массив;
	
	Для Каждого Заголовок Из Заголовки Цикл 
		ПредставлениеЗаголовков.Добавить(СтрШаблон("%1: %2", Заголовок.Ключ, Заголовок.Значение));
	КонецЦикла;
		
	Возврат СтрСоединить(ПредставлениеЗаголовков, Символы.ПС);
	
КонецФункции

Функция КодСостоянияПояснение(КодСостояния)
	
	Если 	  КодСостояния = 100 Тогда Возврат "Continue";
	ИначеЕсли КодСостояния = 101 Тогда Возврат "Switching Protocols";
	ИначеЕсли КодСостояния = 102 Тогда Возврат "Processing";
	
	ИначеЕсли КодСостояния = 200 Тогда Возврат "OK";
	ИначеЕсли КодСостояния = 201 Тогда Возврат "Created";
	ИначеЕсли КодСостояния = 202 Тогда Возврат "Accepted";
	ИначеЕсли КодСостояния = 203 Тогда Возврат "Non-Authoritative Information";
	ИначеЕсли КодСостояния = 204 Тогда Возврат "No Content";
	ИначеЕсли КодСостояния = 205 Тогда Возврат "Reset Content";
	ИначеЕсли КодСостояния = 206 Тогда Возврат "Partial Content";
	ИначеЕсли КодСостояния = 207 Тогда Возврат "Multi-Status";
	ИначеЕсли КодСостояния = 208 Тогда Возврат "Already Reported";
	ИначеЕсли КодСостояния = 226 Тогда Возврат "IM Used";
	
	ИначеЕсли КодСостояния = 300 Тогда Возврат "Multiple Choices";
	ИначеЕсли КодСостояния = 301 Тогда Возврат "Moved Permanently";
	ИначеЕсли КодСостояния = 302 Тогда Возврат "Found";
	ИначеЕсли КодСостояния = 303 Тогда Возврат "See Other";
	ИначеЕсли КодСостояния = 304 Тогда Возврат "Not Modified";
	ИначеЕсли КодСостояния = 305 Тогда Возврат "Use Proxy";
	ИначеЕсли КодСостояния = 306 Тогда Возврат "";
	ИначеЕсли КодСостояния = 307 Тогда Возврат "Temporary Redirect";
	ИначеЕсли КодСостояния = 308 Тогда Возврат "Permanent Redirect";
	
	ИначеЕсли КодСостояния = 400 Тогда Возврат "Bad Request";
	ИначеЕсли КодСостояния = 401 Тогда Возврат "Unauthorized";
	ИначеЕсли КодСостояния = 402 Тогда Возврат "Payment Required";
	ИначеЕсли КодСостояния = 403 Тогда Возврат "Forbidden";
	ИначеЕсли КодСостояния = 404 Тогда Возврат "Not Found";
	ИначеЕсли КодСостояния = 405 Тогда Возврат "Method Not Allowed";
	ИначеЕсли КодСостояния = 406 Тогда Возврат "Not Acceptable";
	ИначеЕсли КодСостояния = 407 Тогда Возврат "Proxy Authentication Required";
	ИначеЕсли КодСостояния = 408 Тогда Возврат "Request Timeout";
	ИначеЕсли КодСостояния = 409 Тогда Возврат "Conflict";
	ИначеЕсли КодСостояния = 410 Тогда Возврат "Gone";
	ИначеЕсли КодСостояния = 411 Тогда Возврат "Length Required";
	ИначеЕсли КодСостояния = 412 Тогда Возврат "Precondition Failed";
	ИначеЕсли КодСостояния = 413 Тогда Возврат "Request Entity Too Large";
	ИначеЕсли КодСостояния = 414 Тогда Возврат "Request-URI Too Long";
	ИначеЕсли КодСостояния = 415 Тогда Возврат "Unsupported Media Type";
	ИначеЕсли КодСостояния = 416 Тогда Возврат "Requested Range Not Satisfiable";
	ИначеЕсли КодСостояния = 417 Тогда Возврат "Expectation Failed";
	ИначеЕсли КодСостояния = 418 Тогда Возврат "I'm a teapot (RFC 2324)";
	ИначеЕсли КодСостояния = 420 Тогда Возврат "Enhance Your Calm (Twitter)";
	ИначеЕсли КодСостояния = 422 Тогда Возврат "Unprocessable Entity";
	ИначеЕсли КодСостояния = 423 Тогда Возврат "Locked";
	ИначеЕсли КодСостояния = 424 Тогда Возврат "Failed Dependency";
	ИначеЕсли КодСостояния = 425 Тогда Возврат "Reserved for WebDAV";
	ИначеЕсли КодСостояния = 426 Тогда Возврат "Upgrade Required";
	ИначеЕсли КодСостояния = 428 Тогда Возврат "Precondition Required";
	ИначеЕсли КодСостояния = 429 Тогда Возврат "Too Many Requests";
	ИначеЕсли КодСостояния = 431 Тогда Возврат "Request Header Fields Too Large";
	ИначеЕсли КодСостояния = 444 Тогда Возврат "No Response (Nginx)";
	ИначеЕсли КодСостояния = 449 Тогда Возврат "Retry With (Microsoft)";
	ИначеЕсли КодСостояния = 450 Тогда Возврат "Blocked by Windows Parental Controls (Microsoft)";
	ИначеЕсли КодСостояния = 451 Тогда Возврат "Unavailable For Legal Reasons";
	ИначеЕсли КодСостояния = 499 Тогда Возврат "Client Closed Request (Nginx)";
	
	ИначеЕсли КодСостояния = 500 Тогда Возврат "Internal Server Error";
	ИначеЕсли КодСостояния = 501 Тогда Возврат "Not Implemented";
	ИначеЕсли КодСостояния = 502 Тогда Возврат "Bad Gateway";
	ИначеЕсли КодСостояния = 503 Тогда Возврат "Service Unavailable";
	ИначеЕсли КодСостояния = 504 Тогда Возврат "Gateway Timeout";
	ИначеЕсли КодСостояния = 505 Тогда Возврат "HTTP Version Not Supported";
	ИначеЕсли КодСостояния = 506 Тогда Возврат "Variant Also Negotiates (Experimental)";
	ИначеЕсли КодСостояния = 507 Тогда Возврат "Insufficient Storage";
	ИначеЕсли КодСостояния = 508 Тогда Возврат "Loop Detected";
	ИначеЕсли КодСостояния = 509 Тогда Возврат "Bandwidth Limit Exceeded (Apache)";
	ИначеЕсли КодСостояния = 510 Тогда Возврат "Not Extended";
	ИначеЕсли КодСостояния = 511 Тогда Возврат "Network Authentication Required";
	ИначеЕсли КодСостояния = 520 Тогда Возврат "Unknown Error";
	ИначеЕсли КодСостояния = 521 Тогда Возврат "Web Server Is Down";
	ИначеЕсли КодСостояния = 522 Тогда Возврат "Connection Timed Out";
	ИначеЕсли КодСостояния = 523 Тогда Возврат "Origin Is Unreachable";
	ИначеЕсли КодСостояния = 524 Тогда Возврат "A Timeout Occurred";
	ИначеЕсли КодСостояния = 525 Тогда Возврат "SSL Handshake Failed";
	ИначеЕсли КодСостояния = 526 Тогда Возврат "Invalid SSL Certificate";
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

Функция ПредставлениеТелаHTTPОбъекта(HTTPОбъект)
	
	Кодировка = "utf-8";
	
	ТипКонтента = HTTPСервисы.ПолучитьЗаголовок(HTTPОбъект, "Content-Type");
	ПозицияКодировки = СтрНайти(ТипКонтента, "charset=");
	Если ПозицияКодировки > 0 Тогда
		Кодировка = Сред(ТипКонтента, ПозицияКодировки + 8);
	КонецЕсли;
	
	ЧтениеТекста = Новый ЧтениеТекста(HTTPОбъект.ПолучитьТелоКакПоток(), Кодировка);
	ТекстТела = ЧтениеТекста.Прочитать(1024 * 15);
	ЧтениеТекста.Закрыть();
	
	Если СтрНайти(ТипКонтента, "text/html") > 0 Тогда
		ТекстТела = СтрЗаменить(ТекстТела, "<br>", Символы.ВК);
		ТекстТела = СтроковыеФункцииКлиентСервер.ИзвлечьТекстИзHTML(ТекстТела);
		ТекстТела = СтрСоединить(СтрРазделить(ТекстТела, Символы.ПС, Ложь), Символы.ПС);
	КонецЕсли;
	
	Возврат ТекстТела;
	
КонецФункции

Процедура ПолучитьОктетBase16(Строка, HexСтрока)
	
	Если СтрНачинаетсяС(Строка, "=") Тогда
		
		Если НЕ (ЭтоСимволBase16(КодСимвола(Строка, 2)) И ЭтоСимволBase16(КодСимвола(Строка, 3))) Тогда
			Возврат;
		КонецЕсли;
		
		HexСтрока = HexСтрока + Сред(Строка, 2, 2);
		Строка = Сред(Строка, 4);
		ПолучитьОктетBase16(Строка, HexСтрока); 
		
	КонецЕсли;
	
КонецПроцедуры

Функция ЭтоСимволBase16(КодСимвола)
	
	Если КодСимвола < 48 ИЛИ КодСимвола > 102 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если (КодСимвола >= 48 И КодСимвола <= 57) Тогда
		Возврат Истина;
	КонецЕсли;
	
	Если (КодСимвола >= 65 И КодСимвола <= 70) Тогда
		Возврат Истина;
	КонецЕсли;
	
	Если (КодСимвола >= 97 И КодСимвола <= 102) Тогда
		Возврат Истина;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

// Служебная функция преобразования нестандартного значения в JSON
//
Функция ПреобразоватьДляJSON(Свойство, Значение, ДополнительныеПараметры, Отказ) Экспорт
	
	Если ТипЗнч(Значение) = Тип("УникальныйИдентификатор") Тогда
		// Нет затрат на получение представления, не кэшируем
		Возврат Строка(Значение);
	КонецЕсли;
	
	Результат = ДополнительныеПараметры.КэшЗначенийОбъектов.Получить(Значение);
	Если Результат = Неопределено Тогда
		Результат = Строка(Значение);
		ДополнительныеПараметры.КэшЗначенийОбъектов.Вставить(Значение, Результат);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

