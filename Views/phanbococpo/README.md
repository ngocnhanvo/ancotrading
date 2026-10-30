# Phân bổ cọc PO -> Invoice

- Gắn ở `Views/chungtuxuatkhoNV/inc-ctxkNV.aspx`, chọn Invoice từ `grid_ds_ctxkNV`.
- PO được liên kết bằng `c_dongpklinv(c_packinginvoice_id, c_donhang_id)`, dùng DISTINCT để tránh PO trùng khi có nhiều dòng sản phẩm.
- Lưới PO lấy `c_donhang.datcoc` và số đã phân bổ từ `c_packinginvoice_phanbo` với Invoice trạng thái HIEULUC.
- Lưới phải đọc chi tiết `c_packinginvoice_phanbo` thuộc Invoice và PO đã chọn; bảng mới chưa có dữ liệu thì trống là đúng.
- `c_dongphanboinv` đang phục vụ Thu Chi, không gộp vào module mới.
- Migration `docs/database/migrations/20261030_c_packinginvoice_phanbo.sql` phải do người có quyền SQL chạy trên DB tương ứng; không tự tạo trong HTTP request.
- Sau migration hãy tạo lại `docs/database/schema-map.json` qua `linq.aspx` và đồng bộ model LINQ nếu cần.
- API `Controller_PhanBoCocPO.ashx?action=load&invoiceId=...` đọc qua SQL, kiểm tra quyền theo Invoice master và trả JSON.
- Preview bật khi query có `phanbococ_preview=1`. Nút thêm/lưu vẫn bị khóa, chưa ghi CSDL và chưa can thiệp hiệu lực chứng từ.
- Pha tiếp theo: kiểm soát lưu bản nháp, áp dụng và hoàn tác khi hiệu lực trong transaction chống phân bổ vượt cọc.