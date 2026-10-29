# Config: resource manager + Settings

```sh
cd services/generation-harness
npm run config
```

Màn hình mặc định là **Global Resources**, theo kiểu `pi config`, không còn là bản sao `/settings`:

```text
Global Resources                 tab switch mode · space toggle · F2 settings · esc close
.../.runtime/agent/settings.json

> 

  npm:your-installed-package (user)
    Extensions
>     [x] extensions/tool.ts
    Skills
      [ ] planning
    Prompts
      [x] prompts/review.md
    Themes
      [x] themes/custom.json
  (1/4)
```

Ví dụ minh họa cách nhóm, không phải package được tự cài. Danh sách thật lấy từ **public native `DefaultPackageManager`**: các package npm/git/local đã có trên đĩa, resource khai báo trực tiếp trong settings và các thư mục auto-discovery. Manifest package của harness dùng khóa `generation` trong `package.json`, theo cơ chế native của bản vendored.

## Điều khiển

- **↑/↓, PageUp/PageDown:** di chuyển/scroll.
- **Gõ chữ:** lọc theo tên package, loại resource, tên hoặc đường dẫn.
- **Space / Enter:** bật/tắt resource tại scope đang chọn; lưu ngay.
- **Tab:** Global ↔ Project. Đường dẫn settings đích luôn hiện ở đầu màn hình.
- **F2:** Resources ↔ Settings; Settings chứa những preference phổ biến như provider/model ID, thinking, theme, transport, hiển thị, compaction, cache warming và retry. Esc ở Settings quay về Resources.
- **Esc / Ctrl+C:** đóng resource manager.

Global dùng `[x]`/`[ ]`. Project giữ các Global resources kế thừa trong danh sách và cho cycle **inherit / load / unload**, ký hiệu explicit `[+]`/`[-]`. Các override chỉ ghi file project, không sửa config Global. Những filter khác, version pin và trường settings không liên quan được giữ nguyên. Khi package có `extensions: []` (tắt tất cả), bật một extension không âm thầm bật các extension còn lại.

Resource được launcher truyền bằng `--extension` luôn được ghi rõ **fixed CLI** và không có toggle giả. Hiện `generation-subagents` thuộc loại này: settings không thể thắng explicit CLI override. Cờ launcher native `--no-extensions` vẫn có semantics riêng; không có thay đổi runtime startup.

## Hai scope

| Scope | File | Áp dụng |
| --- | --- | --- |
| Global / `user` — mặc định | `.runtime/agent/settings.json` | Các phiên dùng cùng runtime, gồm `npm start` và `start:reading` |
| Project / `project` | `.generation/settings.json` | Trusted project cwd, ví dụ `npm run start:reading` |

`GENERATION_HARNESS_RUNTIME_DIR` đổi root của user settings/models/credentials/sessions cùng nhau. **Global ở đây là Global của harness cô lập**, không phải `~/.pi/agent`. Không tự import các package, extension hay credential Pi của bạn. Vì vậy một runtime mới có thể chưa có Global packages; Tab sang Project sẽ thấy resource của checkout, như `reading.ts`.

Native CLI override > trusted project > isolated user > native defaults. `npm start` mặc định dùng scratch workspace nên không tự nhận `.generation/` của checkout này. Project hiện pin bốn built-in tools, tắt cache warming/retry/telemetry cho nghiên cứu; không pin model, thinking hay theme.

```sh
npm run config -- --local               # Vào Project Resources ngay
npm run config -- --scope project       # Tương đương
npm run config -- --settings            # Mở riêng Settings
npm run config -- --resources           # Inventory native dạng JSON
npm run config -- --show                # Preferences + inventory cả hai scope
npm run config -- --paths
npm run config -- --validate            # Schema user/project settings, không probe provider

# Ví dụ sửa preference native, không inference:
npm run config -- --set defaultProvider openai
npm run config -- --set defaultModel YOUR_EXACT_MODEL_ID
npm run config -- --set defaultThinkingLevel high
npm run config -- --scope project --set compaction.keepRecentTokens 20000
npm run config -- --unset defaultModel
```

Không có TTY (CI/redirect), mặc định in JSON inventory và preferences, không mở phiên agent hoặc gửi `/settings` cho model. `--settings` không có TTY chỉ in preferences. `--set`/`--unset` vẫn dành cho preference; resource checkbox ghi native `extensions/skills/prompts/themes` filters hoặc package-filter object.

## Discovery không đồng nghĩa “AI đã đọc trong phiên đang chạy”

Checkbox là **trạng thái cấu hình sau native discovery**, không phải bằng chứng extension đã load thành công, skill đã được model đọc, hay tool đã chạy. Loader còn có validation, name collisions, trust và CLI flags ở lần launch/reload thật. Skills thường chỉ được đọc khi cần. Config không introspect hay thay đổi ngầm phiên đang mở; thay đổi áp dụng ở lần launch/reload tương ứng.

Các npm/git package chưa có hoặc chưa resolve đúng version được đánh dấu unavailable/no resources, **không tự install, clone hay update**. Native auxiliary built-ins mặc định đã bị tắt trong Core frozen; chúng không được giả vờ là active resources. Các extension riêng của một child/role không phải resource auto-discovery của parent.

## Biên an toàn và public SDK

Core frozen vẫn chặn CLI `config` gốc và không export resource-selector UI. Adapter này chỉ dùng **public `DefaultPackageManager`, `SettingsManager` và `generation-tui`**; không import selector private, không sửa `packages/*`, không clone agent loop.

Discovery chạy trong một Node metadata worker với `HOME` trỏ runtime cô lập, native offline mode, callback skip package thiếu, **không có quyền spawn process hay ghi filesystem**, và read allowlist cho checkout/project/runtime. Các probe ngoài biên (gồm symlink escape) bị chặn và báo rõ; không fallback sang global npm hay config ở home thật. Worker không import/evaluate extensions, không chạy package scripts, không đọc auth/models, không login hoặc gọi provider. Node permission là defense-in-depth cho metadata worker, không phải lời hứa sandbox để chạy extension độc hại. Các resource có đường dẫn ngoài project/runtime không được tự khám phá; không coi unavailable là enabled-success.

Ghi settings dùng schema native, atomic rename, mode 0600 và từ chối settings symlink/path escape. Giữ một writer mỗi file; kiểm tra thay đổi đồng thời là optimistic, không phải distributed lock. Với setting native khác chưa có trong bảng preference, chỉnh JSON theo schema local `packages/generation-harness-core/schemas/settings.schema.json`.

## Model endpoints và sampling

Provider/model ID dùng native settings. Endpoint/sampling dùng **isolated agent `models.json`**, không phải resource filter hay settings preference mới. Mẫu: `models.example.json`; chép thủ công vào đường dẫn models do `--paths` trả về rồi sửa provider ID, `.invalid` URL, model ID, context/output limits theo endpoint thật. Không ghi đè file đang dùng. Với custom runtime path, sửa/bỏ `$schema` tương đối trong bản sao.

`apiKey: "$LANGFENS_LLM_API_KEY"` chỉ tham chiếu biến môi trường; không version key thật. `samplingParams.temperature` chỉ áp dụng API OpenAI-compatible mà native hỗ trợ. Không đoán capabilities hay giá từ mẫu. Native `/login` và `/model` trong TUI harness vẫn là thao tác riêng mà bạn chủ động chọn; config không gọi chúng. Không khai báo giá 0 thay unknown khi làm VS4.

## VS4 vẫn offline

Rubric nghiên cứu nằm riêng tại `../evaluation/rubric.json`, versioned/provisional, không phải chuẩn IELTS. Thay rubric phải version hóa, cập nhật fixtures/schema và chạy lại evaluation. Không giảm safety gate bằng resource toggle hay Settings.

Bảng config không tạo model session, không chạy pilot và không cấp quyền LIVE/publication/student delivery. Bật extension chỉ thay đổi cấu hình; lần launch thật có thể chạy code extension nên chỉ enable code bạn tin cậy. Offline tests dùng credential sanitizer/network guard; không có live inference, package download, commit hay push trong task này.
