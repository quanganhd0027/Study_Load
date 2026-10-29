# StudyLoad — bản demo có màn hình đăng nhập

## Những gì có trong bản này

- Trang bắt đầu với **Đăng nhập / Đăng kí**.
- Đăng kí có các trường: Tên đăng kí (bắt buộc), Mã học sinh (không bắt buộc), Lớp (không bắt buộc), Email (bắt buộc), Mật khẩu (bắt buộc).
- Đăng nhập bằng tên đăng kí hoặc email và mật khẩu.
- Tài khoản mới mặc định là học sinh.
- Nút hình tài khoản cho phép học sinh gửi yêu cầu quyền giáo viên.
- Tài khoản quản trị có khu vực duyệt/từ chối yêu cầu, nhập và xuất bản sao lưu.
- Dữ liệu nhiệm vụ, lớp học, dự án và lịch bắt đầu **trống**. Không tự nạp dữ liệu mẫu.

## Tài khoản quản trị trong bản demo

Email quản trị được chuẩn bị sẵn: `quanganhd2011@gmail.com`.

Lần đầu đăng nhập, nhập email này và gõ mật khẩu mới (tối thiểu 8 ký tự). Bản demo sẽ lưu mật khẩu đã băm trong bộ nhớ trình duyệt.

## Chạy thử

Mở `index.html` bằng trình duyệt hoặc chạy:

```bash
python -m http.server 8000
```

Sau đó mở `http://localhost:8000`.

## CẢNH BÁO BẢO MẬT — đọc trước khi đưa lên website công khai

Đây vẫn là **bản demo frontend**, không phải hệ thống đăng nhập an toàn để dùng thật. Tài khoản, mật khẩu đã băm, phiên đăng nhập, yêu cầu giáo viên và dữ liệu ứng dụng lưu trong `localStorage` của trình duyệt. Người dùng khác thiết bị không nhận được yêu cầu phê duyệt; dữ liệu không tự đồng bộ giữa các máy.

Do không có máy chủ, việc tạo/quản lý quyền quản trị phía trình duyệt không thể bảo mật: người dùng có thể sửa JavaScript hoặc dữ liệu lưu cục bộ. **Không dùng bản này để lưu dữ liệu học sinh thật hoặc mở quyền admin trên website công khai.**

Để triển khai thực tế cần backend và cơ sở dữ liệu dùng chung (ví dụ Supabase): xác thực phía máy chủ, vai trò lưu trong database, chính sách RLS, và chỉ tài khoản admin được quyền duyệt giáo viên / xuất dữ liệu. Các khóa bí mật không được đặt trong `app.js`.

## Kiểm tra

`app.js` đã được kiểm tra cú pháp bằng `node --check`. Chưa thay thế kiểm thử trình duyệt hoặc kiểm thử bảo mật.
