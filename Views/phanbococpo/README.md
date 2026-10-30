# Phân bổ cọc PO -> Invoice

- Gắn ở `Views/chungtuxuatkhoNV/inc-ctxkNV.aspx`, chọn Invoice từ `grid_ds_ctxkNV`.
- PO được liên kết bằng `c_dongpklinv(c_packinginvoice_id, c_donhang_id)`, dùng DISTINCT để tránh PO trùng khi có nhiều dòng sản phẩm.
- Lưới PO lấy `c_donhang.datcoc` và số đã phân bổ từ `c_packinginvoice_phanbo` với Invoice trạng thái HIEULUC.
- Lưới phải đọc chi tiết `c_packinginvoice_phanbo` thuộc Invoice và PO đã chọn; bảng mới chưa có dữ liệu thì trống là đúng.
- `c_dongphanboinv` đang phục vụ Thu Chi, không gộp vào module mới.
- Migration `docs/database/migrations/20261030_c_packinginvoice_phanbo.sql` phải do người có quyền SQL chạy trên DB tương ứng; không tự tạo trong HTTP request.
- Sau migration hãy tạo lại `docs/database/schema-map.json` qua `linq.aspx` và đồng bộ model LINQ nếu cần.
- API `Controller_PhanBoCocPO.ashx?action=load&invoiceId=...` đọc qua SQL, kiểm tra quyền theo Invoice master và trả JSON.
- Tab `Phân bổ cọc` hiển thị mặc định trong `Chứng từ XK` mà không cần query string. Quyền ghi bản nháp vẫn do cấu hình server `EnablePOAllocationDraftSave` quyết định; mặc định khóa, không tự bật khi mở tab.
- Pha tiếp theo: kiểm soát lưu bản nháp, áp dụng và hoàn tác khi hiệu lực trong transaction chống phân bổ vượt cọc.
- Do phần `Chứng từ XK` được thêm bằng jQuery UI AJAX tab, JavaScript phân bổ phải nạp qua `window.ancoEnsurePhanBoCocPONV` từ `inc-ctxkNV.aspx` sau khi tab được thêm vào DOM. Hàm này dùng `$.getScript` một lần, rồi `init + syncInvoice`, tránh tình trạng `setInvoice` đến trước `init` làm API không được gọi. Khi mở lại tab, module phát hiện DOM jqGrid mới và tái khởi tạo.

## Pha lưu thử bản nháp (chưa hiệu lực)

- API POST `action=save` lưu các dòng `c_packinginvoice_phanbo`, **chỉ khi SOANTHAO**, và chỉ cho tài khoản admin trong giai đoạn thử.
- POST yêu cầu CSRF token của Session; kiểm tra PO thực sự thuộc Invoice, số tiền >0, tối đa 2 số lẻ, tổng theo PO không vượt `c_donhang.datcoc - cọc đã phân bổ bởi INV HIEULUC`.
- Sử dụng một giao dịch SQL `SERIALIZABLE`, khóa Invoice và các PO, kiểm tra version để từ chối lưu đè bản nháp thay đổi bởi phiên khác.
- Có thể thêm/sửa/xóa nhiều dòng phân bổ. Không tạo khóa ngoài SQL thật.
- **Mặc định server luôn từ chối ghi**. Chỉ trên Web.config của máy **TEST**, thêm vào `<appSettings>`: `<add key="EnablePOAllocationDraftSave" value="true" />`. Không commit mật khẩu, không bật cờ này trên production.
- Không thay đổi `c_packinginvoice.tiendatcoc`, `tiendatcocPO` và không tác động trạng thái HIEULUC. Hai cột tiền đang có dữ liệu nghiệp vụ khác; cần xác minh cách cộng tổng trước khi tích hợp.
- Dữ liệu test trong GitHub Secrets là database TEST. Workflow `test-po-allocation-sql-transaction.yml` đã chạy INSERT/UPDATE/DELETE và ROLLBACK thành công, không lưu dòng thử.
