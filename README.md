# BT Earbuds Touch Sensor Lock & GATT Configurator (A15 Edition)

ระบบตั้งค่าและล็อกเซ็นเซอร์สัมผัสหูฟังบลูทูธ (รองรับหูฟังบลูทูธรุ่น **A15** โดยเฉพาะ และหูฟัง TWS ทุกรุ่น) แก้ปัญหาเซ็นเซอร์สัมผัสหูฟังรวน เปลี่ยนเพลงเอง หยุดเพลงเอง หรือปิดเครื่องเองเมื่อฟังไปสักพัก

## ฟีเจอร์หลัก (Key Features)
- **A15 Dedicated Profile & Windows Hardware Bridge**: เชื่อมต่อตรงกับหูฟัง `A15` ผ่าน Bluetooth Serial (`COM4` SPP `0x1101`), `A15 Avrcp Transport` (`0x110E` / `0x110C`), และ Windows CoreAudio
- **Live Audio & Now Playing Marquee Monitor**: แถบตัววิ่งกรอบสีเขียวแสดงชื่อเพลง/คลิปที่กำลังเปิดฟังสด, แหล่งที่มาของเสียง (Browser / Media Player), สถานะ `กำลังเล่น (PLAYING)` / `หยุดชั่วคราว (PAUSED)` และระดับสัญญาณเสียงสด (Live VU Peak Meter)
- **Master & Granular Touch Sensor Lock / Unlock**: ล็อกและปลดล็อกเซ็นเซอร์สัมผัสได้ถาวรหรือสลับเปิด-ปิดแยกแต่ละปุ่ม (แตะ 1 ครั้ง, 2 ครั้ง, 3 ครั้ง, แตะค้างปิดเครื่อง)
- **BLE GATT String & Hex Explorer**: อ่าน/เขียนค่า String (UTF-8) และ Hex Bytes พร้อมบันทึกเป็นโปรไฟล์สลับเปิด-ปิดถาวร
- **OS-Level & Browser AVRCP Ghost-Touch Shield + 18Hz Keep-Alive**: ดักจับและบล็อกคำสั่งปุ่มลั่นระดับ Windows (`WH_KEYBOARD_LL`) และส่งคลื่นความถี่ต่ำกันหูฟังตัดดับเอง
- **Real-time 6 Languages & 5 Currencies + Dark/Light Mode**:
  - 6 ภาษา: `th`, `en`, `zh-CN`, `zh-TW`, `ja`, `ms`
  - 5 สกุลเงิน: `THB`, `USD`, `CNY`, `JPY`, `MYR`

## วิธีรันใช้งาน (Quick Start)
```bash
npm install
npm run dev
```
เปิดเบราว์เซอร์ที่ `http://localhost:5173`
