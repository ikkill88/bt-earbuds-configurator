import { Language } from './i18n';

export interface ChipsetPreset {
  id: string;
  name: string;
  serviceUuid: string;
  charUuid: string;
  lockHex: string;
  unlockHex: string;
  lockString: string;
  unlockString: string;
  description: Record<Language, string>;
  granularCommands: {
    singleTap: { lockHex: string; unlockHex: string };
    doubleTap: { lockHex: string; unlockHex: string };
    tripleTap: { lockHex: string; unlockHex: string };
    longPress: { lockHex: string; unlockHex: string };
    inEarDetect: { lockHex: string; unlockHex: string };
    autoPowerOff: { lockHex: string; unlockHex: string };
  };
}

export const OPTIONAL_BLE_SERVICES: string[] = [
  'battery_service',
  'device_information',
  'generic_access',
  'generic_attribute',
  '0000ffe0-0000-1000-8000-00805f9b34fb', // A15 TWS (Bluetrum / HM UART BLE)
  '0000fff0-0000-1000-8000-00805f9b34fb', // A15 TWS Vendor Config Service
  '0000ae00-0000-1000-8000-00805f9b34fb', // A15 TWS (JieLi JL RCSP BLE)
  '0000fd00-0000-1000-8000-00805f9b34fb', // A15 / F9 TWS Control Service
  '0000fd2d-0000-1000-8000-00805f9b34fb', // Xiaomi / Redmi Buds
  '0000ff12-0000-1000-8000-00805f9b34fb', // Generic TWS Control Service
  '00001100-d102-11e1-9b23-00025b00a5a5', // Qualcomm QCC / CSR GAIA
  '5052494d-2dab-0341-6972-6f6861424c45', // Airoha Race BLE Service
  '01001100-0000-1000-8000-00805f9b34fb', // Soundcore / Anker BLE
];

export const CHIPSET_PRESETS: ChipsetPreset[] = [
  {
    id: 'a15-tws-dedicated',
    name: '⭐ A15 TWS (Dedicated A15 Profile - JL AC6976 / Bluetrum AB5616)',
    serviceUuid: '0000ffe0-0000-1000-8000-00805f9b34fb',
    charUuid: '0000ffe1-0000-1000-8000-00805f9b34fb',
    lockHex: 'AA 55 06 A1 05 00 00 00 A6',
    unlockHex: 'AA 55 06 A1 05 01 01 01 A9',
    lockString: 'AT+A15_TOUCH=LOCK,0,NOPOWEROFF',
    unlockString: 'AT+A15_TOUCH=UNLOCK,1,DEFAULT',
    description: {
      th: 'โปรไฟล์เฉพาะสำหรับหูฟังบลูทูธรุ่น "A15" (ใช้ชิป JL AC6976 / Bluetrum AB5616) แก้อาการเซ็นเซอร์ A15 ลั่นเปลี่ยนเพลงเองและปิดเครื่องเองเมื่อฟังไปสักพัก',
      en: 'Dedicated profile for "A15" Bluetooth earbuds (JL AC6976 / Bluetrum AB5616) fixing random track skipping and self power-off after listening',
      'zh-CN': '“A15”蓝牙耳机专属配置文件（杰理 AC6976 / 中科蓝讯 AB5616 方案），专门解决 A15 听歌一会后自动切歌或自动关机问题',
      'zh-TW': '「A15」藍牙耳機專屬設定檔（傑理 AC6976 / 中科藍訊 AB5616 方案），專門解決 A15 聽歌一陣子後自動換歌或自動關機問題',
      ja: '「A15」Bluetoothイヤホン専用プロファイル（JL AC6976 / Bluetrum AB5616）。しばらく聴くと勝手に曲送りや電源オフになる症状を防止',
      ms: 'Profil khas untuk fon telinga Bluetooth "A15" (JL AC6976 / Bluetrum AB5616) mengatasi masalah tukar lagu sendiri dan mati sendiri',
    },
    granularCommands: {
      singleTap: { lockHex: 'AA 55 05 A1 01 00 00 A2', unlockHex: 'AA 55 05 A1 01 01 01 A4' },
      doubleTap: { lockHex: 'AA 55 05 A1 02 00 00 A3', unlockHex: 'AA 55 05 A1 02 02 02 A7' },
      tripleTap: { lockHex: 'AA 55 05 A1 03 00 00 A4', unlockHex: 'AA 55 05 A1 03 03 03 AA' },
      longPress: { lockHex: 'AA 55 05 A1 04 00 00 A5', unlockHex: 'AA 55 05 A1 04 04 04 AD' },
      inEarDetect: { lockHex: 'AA 55 04 A1 08 00 A9', unlockHex: 'AA 55 04 A1 08 01 AA' },
      autoPowerOff: { lockHex: 'AA 55 04 A1 09 00 AA', unlockHex: 'AA 55 04 A1 09 01 AB' },
    },
  },
  {
    id: 'jieli-rcsp',
    name: 'JieLi / JL (AC6976 / AC7006 RCSP Protocol - A15 Alt)',
    serviceUuid: '0000ae00-0000-1000-8000-00805f9b34fb',
    charUuid: '0000ae01-0000-1000-8000-00805f9b34fb',
    lockHex: 'FE DC BA C0 08 00 04 01 00 00 00 EF',
    unlockHex: 'FE DC BA C0 08 00 04 01 01 02 03 EF',
    lockString: 'JL+KEY_LOCK=1',
    unlockString: 'JL+KEY_LOCK=0',
    description: {
      th: 'ชิป JieLi (JL) ที่ใช้ในบอร์ดหูฟัง A15 ล็อตมาตรฐาน (ส่งเฟรม RCSP Key Map = 0x00 เพื่อปิดปุ่มสัมผัสทั้งซ้ายและขวา)',
      en: 'JieLi (JL) chipset used in standard A15 boards (writes RCSP Key Map = 0x00 to disable L/R touch pads)',
      'zh-CN': 'A15 标准版主控杰理 (JieLi) 蓝牙芯片（发送 RCSP 按键映射 0x00 关闭左右耳触控）',
      'zh-TW': 'A15 標準版主控傑理 (JieLi) 藍牙晶片（發送 RCSP 按鍵映射 0x00 關閉左右耳觸控）',
      ja: 'A15標準ボード搭載のJieLi (JL) チップ（RCSPキーマップ0x00書き込みで左右タッチ無効化）',
      ms: 'Cip JieLi (JL) dalam papan A15 standard (RCSP Key Map = 0x00 untuk mematikan sentuhan L/R)',
    },
    granularCommands: {
      singleTap: { lockHex: 'FE DC BA C0 08 00 02 01 00 EF', unlockHex: 'FE DC BA C0 08 00 02 01 01 EF' },
      doubleTap: { lockHex: 'FE DC BA C0 08 00 02 02 00 EF', unlockHex: 'FE DC BA C0 08 00 02 02 03 EF' },
      tripleTap: { lockHex: 'FE DC BA C0 08 00 02 03 00 EF', unlockHex: 'FE DC BA C0 08 00 02 03 04 EF' },
      longPress: { lockHex: 'FE DC BA C0 08 00 02 04 00 EF', unlockHex: 'FE DC BA C0 08 00 02 04 05 EF' },
      inEarDetect: { lockHex: 'FE DC BA C0 09 00 01 00 EF', unlockHex: 'FE DC BA C0 09 00 01 01 EF' },
      autoPowerOff: { lockHex: 'FE DC BA C0 0A 00 01 00 EF', unlockHex: 'FE DC BA C0 0A 00 01 01 EF' },
    },
  },
  {
    id: 'bluetrum-ab',
    name: 'Bluetrum (AB5616 / AB5376 / FFF0 Config - A15 V2)',
    serviceUuid: '0000fff0-0000-1000-8000-00805f9b34fb',
    charUuid: '0000fff1-0000-1000-8000-00805f9b34fb',
    lockHex: 'AA 55 04 20 00 00 24',
    unlockHex: 'AA 55 04 20 01 01 26',
    lockString: 'BT+TOUCH_EN=0',
    unlockString: 'BT+TOUCH_EN=1',
    description: {
      th: 'ชิป Bluetrum สำหรับหูฟัง A15 บอร์ดรุ่น V2 ใช้เซอร์วิส FFF0/FFE0 ในการล็อกปุ่มแตะและปิด Long-Press Shutdown',
      en: 'Bluetrum chipset for A15 V2 board using FFF0/FFE0 GATT service to lock touch and disable long-press shutdown',
      'zh-CN': 'A15 V2 版中科蓝讯 (Bluetrum) 芯片，通过 FFF0/FFE0 服务锁定触控并禁用长按关机',
      'zh-TW': 'A15 V2 版中科藍訊 (Bluetrum) 晶片，透過 FFF0/FFE0 服務鎖定觸控並停用長按關機',
      ja: 'A15 V2ボード用Bluetrumチップセット（FFF0/FFE0サービス経由でタッチ設定と長押し電源オフを無効化）',
      ms: 'Cip Bluetrum untuk papan A15 V2 menggunakan servis FFF0/FFE0 untuk mengunci sentuhan',
    },
    granularCommands: {
      singleTap: { lockHex: 'AA 55 04 21 01 00 26', unlockHex: 'AA 55 04 21 01 01 27' },
      doubleTap: { lockHex: 'AA 55 04 21 02 00 27', unlockHex: 'AA 55 04 21 02 02 29' },
      tripleTap: { lockHex: 'AA 55 04 21 03 00 28', unlockHex: 'AA 55 04 21 03 03 2B' },
      longPress: { lockHex: 'AA 55 04 21 04 00 29', unlockHex: 'AA 55 04 21 04 04 2D' },
      inEarDetect: { lockHex: 'AA 55 03 22 00 25', unlockHex: 'AA 55 03 22 01 26' },
      autoPowerOff: { lockHex: 'AA 55 03 23 00 26', unlockHex: 'AA 55 03 23 01 27' },
    },
  },
  {
    id: 'airoha-race',
    name: 'Airoha (AB1562 / AB1536 / RACE Protocol)',
    serviceUuid: '5052494d-2dab-0341-6972-6f6861424c45',
    charUuid: '43484152-2dab-3241-6972-6f6861424c45',
    lockHex: '05 5A 06 00 01 0E 00 00 00 00',
    unlockHex: '05 5A 06 00 01 0E 01 01 01 01',
    lockString: 'AT+TOUCH=LOCK,ALL,0',
    unlockString: 'AT+TOUCH=UNLOCK,ALL,1',
    description: {
      th: 'ชิป Airoha ในหูฟัง TWS ระดับกลาง-สูง (ใช้คำสั่ง RACE NVKey ปิด Touch Pad)',
      en: 'Airoha chipset used in mid/high-tier TWS earbuds (RACE NVKey touch lock)',
      'zh-CN': 'Airoha (络达) 芯片（通过 RACE NVKey 禁用触控）',
      'zh-TW': 'Airoha (絡達) 晶片（透過 RACE NVKey 停用觸控）',
      ja: 'Airohaチップセット（RACE NVKeyによりタッチパッドを無効化）',
      ms: 'Cip Airoha dalam TWS pertengahan/tinggi (kunci sentuh RACE NVKey)',
    },
    granularCommands: {
      singleTap: { lockHex: '05 5A 05 00 01 0E 01 00', unlockHex: '05 5A 05 00 01 0E 01 01' },
      doubleTap: { lockHex: '05 5A 05 00 01 0E 02 00', unlockHex: '05 5A 05 00 01 0E 02 02' },
      tripleTap: { lockHex: '05 5A 05 00 01 0E 03 00', unlockHex: '05 5A 05 00 01 0E 03 03' },
      longPress: { lockHex: '05 5A 05 00 01 0E 04 00', unlockHex: '05 5A 05 00 01 0E 04 04' },
      inEarDetect: { lockHex: '05 5A 05 00 01 0F 00 00', unlockHex: '05 5A 05 00 01 0F 00 01' },
      autoPowerOff: { lockHex: '05 5A 05 00 01 10 00 00', unlockHex: '05 5A 05 00 01 10 00 01' },
    },
  },
  {
    id: 'qualcomm-gaia',
    name: 'Qualcomm QCC (QCC3040 / QCC3071 / GAIA v3)',
    serviceUuid: '00001100-d102-11e1-9b23-00025b00a5a5',
    charUuid: '00001101-d102-11e1-9b23-00025b00a5a5',
    lockHex: 'FF 03 00 02 00 1D 01 1F 00',
    unlockHex: 'FF 03 00 02 00 1D 01 1F 01',
    lockString: 'GAIA:UI_TOUCH_LOCK=TRUE',
    unlockString: 'GAIA:UI_TOUCH_LOCK=FALSE',
    description: {
      th: 'ชิป Qualcomm QCC สั่งล็อก Touch UI ผ่านโปรโตคอล GAIA',
      en: 'Qualcomm QCC earbuds locking Touch UI via GAIA command protocol',
      'zh-CN': '高通 QCC 系列芯片，通过 GAIA 协议锁定触控板',
      'zh-TW': '高通 QCC 系列晶片，透過 GAIA 協定鎖定觸控板',
      ja: 'Qualcomm QCC搭載イヤホン。GAIAプロトコルでタッチUIをロック',
      ms: 'Cip Qualcomm QCC mengunci UI Sentuh melalui protokol GAIA',
    },
    granularCommands: {
      singleTap: { lockHex: 'FF 03 00 02 00 1D 01 20 00', unlockHex: 'FF 03 00 02 00 1D 01 20 01' },
      doubleTap: { lockHex: 'FF 03 00 02 00 1D 01 21 00', unlockHex: 'FF 03 00 02 00 1D 01 21 01' },
      tripleTap: { lockHex: 'FF 03 00 02 00 1D 01 22 00', unlockHex: 'FF 03 00 02 00 1D 01 22 01' },
      longPress: { lockHex: 'FF 03 00 02 00 1D 01 23 00', unlockHex: 'FF 03 00 02 00 1D 01 23 01' },
      inEarDetect: { lockHex: 'FF 03 00 02 00 1D 01 24 00', unlockHex: 'FF 03 00 02 00 1D 01 24 01' },
      autoPowerOff: { lockHex: 'FF 03 00 02 00 1D 01 25 00', unlockHex: 'FF 03 00 02 00 1D 01 25 01' },
    },
  },
];

export function hexToBytes(hex: string): Uint8Array {
  const clean = hex.replace(/[^0-9A-Fa-f]/g, '');
  const len = Math.floor(clean.length / 2);
  const bytes = new Uint8Array(len);
  for (let i = 0; i < len; i++) {
    bytes[i] = parseInt(clean.substring(i * 2, i * 2 + 2), 16);
  }
  return bytes;
}

export function stringToBytes(str: string): Uint8Array {
  return new TextEncoder().encode(str);
}

export function bytesToHex(bytes: Uint8Array): string {
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, '0').toUpperCase())
    .join(' ');
}

export function bytesToString(bytes: Uint8Array): string {
  try {
    const decoded = new TextDecoder('utf-8', { fatal: false }).decode(bytes);
    return decoded.replace(/[\x00-\x1F\x7F]/g, '·');
  } catch {
    return '';
  }
}
