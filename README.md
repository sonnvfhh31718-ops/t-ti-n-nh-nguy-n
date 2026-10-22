# Gia Phả Tổ Tiên

Website gia phả tiếng Việt với giao diện xanh rêu/vàng đồng, cây gia phả theo thế hệ, ảnh chân dung, tài khoản đăng nhập và quyền quản trị.

## Trạng thái hiện tại

- `index.html`: giao diện web và logic Supabase Auth/Database/Storage.
- `config.js`: cấu hình công khai cho Supabase (cần tạo từ file mẫu).
- `supabase/schema.sql`: bảng, Row Level Security (RLS), chính sách ảnh riêng tư.
- Cần tự tạo dự án Supabase và bật GitHub Pages hoặc host tĩnh. Mã nguồn đã được cập nhật, nhưng website trực tuyến chưa hoạt động cho đến khi hoàn thành cấu hình.

## 1. Tạo cơ sở dữ liệu và đăng nhập

1. Mở https://supabase.com/dashboard và tạo một project mới.
2. Trong project, mở **SQL Editor → New query**.
3. Sao chép toàn bộ nội dung `supabase/schema.sql` của repository vào SQL Editor, rồi bấm **Run**.
4. Vào **Project Settings → API** (hoặc Connect) để lấy **Project URL** và **publishable/anon key**. Chỉ dùng khóa publishable/anon trong website; tuyệt đối không đưa `service_role` hoặc secret key vào trình duyệt hay GitHub.
5. Tạo file `config.js` ở thư mục gốc bằng cách sao chép `config.example.js`, rồi thay giá trị mẫu:
   ```js
   window.GIA_PHA_CONFIG = {
     url: "https://YOUR_PROJECT.supabase.co",
     anonKey: "YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY"
   };
   ```
   Commit file `config.js` sau khi điền hai giá trị công khai này. Nếu muốn tránh commit cấu hình, hãy triển khai qua quy trình build có biến môi trường; GitHub Pages thuần không tự thay biến môi trường.
6. Trong **Authentication → URL Configuration**, đặt **Site URL** thành URL GitHub Pages của bạn, ví dụ `https://OWNER.github.io/REPO/`. Thêm cùng URL vào **Redirect URLs**.
7. Trong **Authentication → Providers → Email**, bật email/password. Tắt đăng ký công khai nếu chỉ quản trị viên được phép tạo tài khoản.

## 2. Tạo tài khoản quản trị đầu tiên

1. Vào **Authentication → Users → Add user**, tạo email và mật khẩu của bạn.
2. Mở SQL Editor, thay `YOUR_ADMIN_EMAIL` bằng email chính xác, rồi chạy:
   ```sql
   insert into public.profiles (user_id, role, display_name)
   select id, 'admin', 'Quản trị gia phả'
   from auth.users
   where email = 'YOUR_ADMIN_EMAIL'
   on conflict (user_id) do update set role = 'admin';
   ```
3. Mở website, đăng nhập bằng tài khoản đó. Nút **Thêm thành viên** sẽ xuất hiện.

Để tạo tài khoản thành viên khác, thêm user trong **Authentication → Users**, sau đó thêm hồ sơ vai trò `member`:
```sql
insert into public.profiles (user_id, role, display_name)
select id, 'member', 'Tên thành viên'
from auth.users
where email = 'EMAIL_THANH_VIEN';
```
Chỉ người có role `admin` mới được thêm/sửa/xóa thành viên hoặc tải ảnh. Người dùng đã đăng nhập có thể đọc hồ sơ gia phả.

## 3. Triển khai GitHub Pages

1. Mở repository GitHub → **Settings → Pages**.
2. Chọn **Deploy from a branch**, branch `main`, folder `/(root)`, rồi Save.
3. Chờ GitHub Pages hoàn tất. URL thường là `https://OWNER.github.io/REPO/`.
4. Đặt URL thực tế đó vào Supabase Authentication → URL Configuration.
5. Mở URL website, thử đăng nhập, thêm một hồ sơ và tải ảnh lên.

## 4. Ảnh chân dung và quyền riêng tư

- Ảnh được lưu trong bucket riêng tư `ancestor-portraits`, tối đa 5 MB/ảnh; chỉ tài khoản đã đăng nhập được đọc.
- Không đưa thông tin nhạy cảm, số giấy tờ, địa chỉ nhà chi tiết hoặc dữ liệu gia đình không được đồng ý lên website công khai.
- Hãy sao lưu dữ liệu định kỳ. Có thể thêm chức năng xuất/nhập dữ liệu ở các phiên bản tiếp theo.

## Khắc phục lỗi thường gặp

- **Chưa cấu hình Supabase**: kiểm tra file `config.js`, URL và publishable/anon key.
- **Đăng nhập được nhưng không thấy nút quản trị**: chạy câu SQL gán role `admin` và đăng nhập lại.
- **Lỗi quyền truy cập/RLS**: kiểm tra đã chạy toàn bộ `schema.sql` và user có bản ghi trong `profiles`.
- **Ảnh không tải được**: kiểm tra bucket `ancestor-portraits` và các policy trong schema.
