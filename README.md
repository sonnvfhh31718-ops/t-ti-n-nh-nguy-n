# Gia Phả Tổ Tiên

Website gia phả tiếng Việt với giao diện xanh rêu/vàng đồng, cây gia phả theo thế hệ, ảnh chân dung, tài khoản đăng nhập và quyền quản trị.

## Trạng thái hiện tại

- `index.html`: giao diện web và logic Supabase Auth/Database/Storage.
- `config.js`: cấu hình công khai cho Supabase (cần tạo từ file mẫu).
- `supabase/schema.sql`: bảng, Row Level Security (RLS), chính sách ảnh riêng tư.
- Cần tự tạo dự án Supabase và bật GitHub Pages hoặc host tĩnh. Mã nguồn đã được cập nhật, nhưng website trực tuyến chưa hoạt động cho đến khi hoàn thành cấu hình.


## Supabase đã kết nối

Dự án Supabase đã tạo và kết nối vào `config.js`:
- Project: `gia-pha-to-tien`
- Project URL: `https://cdvkcjxltwttfxyjzrck.supabase.co`
- Database tables: `profiles`, `family_members`
- Storage bucket: `ancestor-portraits` (private, ảnh tối đa 5 MB)
- RLS được bật để chỉ người đăng nhập đọc dữ liệu; chỉ role `admin` mới được thay đổi hồ sơ và tải ảnh.

### Tạo tài khoản quản trị đầu tiên

Vì mật khẩu là thông tin riêng tư, hãy tự tạo tài khoản trong Supabase Dashboard:
1. Mở [Authentication → Users](https://supabase.com/dashboard/project/cdvkcjxltwttfxyjzrck/auth/users).
2. Chọn **Add user** / **Create new user**, nhập email của bạn và đặt mật khẩu mạnh. Không gửi mật khẩu cho người khác.
3. Mở [SQL Editor](https://supabase.com/dashboard/project/cdvkcjxltwttfxyjzrck/sql/new), chạy truy vấn dưới đây sau khi thay `EMAIL_CUA_BAN` bằng email vừa tạo (giữ dấu nháy đơn):
   ```sql
   insert into public.profiles (user_id, role, display_name)
   select id, 'admin', 'Quản trị gia phả'
   from auth.users
   where lower(email) = lower('EMAIL_CUA_BAN')
   on conflict (user_id) do update set role = 'admin';
   ```
4. Trong [Authentication → URL Configuration](https://supabase.com/dashboard/project/cdvkcjxltwttfxyjzrck/auth/url-configuration), đặt **Site URL** là `https://sonnvfhh31718-ops.github.io/t-ti-n-nh-nguy-n/` và thêm đúng URL đó vào **Redirect URLs**.
5. Mở [website Gia Phả Tổ Tiên](https://sonnvfhh31718-ops.github.io/t-ti-n-nh-nguy-n/), đăng nhập bằng email và mật khẩu đã tạo. Hãy thử thêm một thành viên và tải ảnh để kiểm tra.

### Thêm tài khoản thành viên

Tạo người dùng tại Authentication → Users, rồi thêm hồ sơ quyền thành viên trong SQL Editor:
```sql
insert into public.profiles (user_id, role, display_name)
select id, 'member', 'Tên thành viên'
from auth.users
where lower(email) = lower('EMAIL_THANH_VIEN')
on conflict (user_id) do update set role = 'member';
```
Không bật đăng ký công khai nếu chỉ muốn quản trị viên tạo tài khoản. Chỉ dùng publishable/anon key trong `config.js`; tuyệt đối không đưa service_role/secret key vào GitHub hoặc trình duyệt.


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


### Trang đăng nhập và đăng ký riêng

- Đăng nhập: `https://sonnvfhh31718-ops.github.io/t-ti-n-nh-nguy-n/login.html`
- Đăng ký: `https://sonnvfhh31718-ops.github.io/t-ti-n-nh-nguy-n/register.html`
- Khi đăng ký, Supabase Auth lưu tài khoản và trigger tự tạo dòng trong `public.profiles` với quyền mặc định `member`. Nếu dự án bật xác nhận email, người dùng phải bấm liên kết xác nhận trong email trước khi đăng nhập.
- Để cấp quyền quản trị cho tài khoản đã đăng ký, mở SQL Editor của đúng dự án `cdvkcjxltwttfxyjzrck` và chạy (thay email mẫu):
  ```sql
  update public.profiles
  set role = 'admin'
  where user_id = (
    select id from auth.users
    where lower(email) = lower('EMAIL_CUA_BAN')
  );
  ```
- Chỉ dùng publishable/anon key trong `config.js`; tuyệt đối không đưa service_role/secret key vào GitHub hoặc trình duyệt.

