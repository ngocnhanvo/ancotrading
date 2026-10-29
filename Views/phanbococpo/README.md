# Giao diện phân bổ cọc PO -> Invoice (giai đoạn 1)

- Điểm tích hợp: tab \`Phân bổ cọc\` trong \`Views/chungtuxuatkhoNV/inc-ctxkNV.aspx\` (bên cạnh Các dòng hàng).
- Module riêng: \`phanbococpo.ascx\`, \`phanbococpo.ascx.cs\`, \`phanbococpo.js\`, \`phanbococpo.css\`.
- Controller dự phòng: \`Controller_PhanBoCocPO.ashx\`, cố ý trả HTTP 501 (không thực hiện ghi dữ liệu).
- Tab được ẩn trong hoạt động bình thường. Để xem, tải trang AncoTrading với query \`phanbococ_preview=1\` rồi vào mục Packing List - Invoice và chọn Invoice.
- Toàn bộ PO, số tiền và dòng phân bổ trong chế độ preview đều là dữ liệu minh họa cục bộ, KHÔNG phải dữ liệu thật của Invoice được chọn.
- Chế độ preview cho thử: chọn PO, thêm/sửa/xóa dòng, tính cọc trước/sau, kiểm tra không vượt số dư, chuyển soạn thảo/hiệu lực để kiểm tra trạng thái khóa.
- Nút \`Lưu (PB)\` luôn vô hiệu trong giai đoạn này. Không sửa bảng CSDL, trạng thái, hay endpoint phân bổ Thu Chi cũ.
- Giai đoạn 2 cần thiết kế bảng lưu PO–Invoice, nguồn tiền cọc thực, API đọc/lưu, trạng thái soạn thảo, kiểm tra số dư trong transaction khi hiệu lực, hủy hiệu lực và hồi quy.
- Trước khi mở tab cho người dùng chính thức: bỏ dữ liệu mẫu, hoàn tất backend, kiểm thử, rồi bỏ feature gate.

- Giao diện tự điều chỉnh chiều cao theo vùng nội dung sau thanh tab; thanh tổng tiền ở dưới luôn hiển thị, còn jqGrid PO và chi tiết cuộn độc lập khi nhiều dòng.
