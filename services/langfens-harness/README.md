# langfens-harness

Node.js agent runtime dành cho Langfens, được tối giản từ [Pi v1.4.0](https://github.com/earendil-works/pi/tree/v1.4.0), commit `4a080252f06caf63a525d7873c5d94d3c23887e0`.

Subsystem Node.js độc lập, không dùng Pi global hoặc configuration/dependencies từ host. Giữ Pi Core, SDK, session/context management, RPC, extension mechanism và TUI. Có Dockerfile độc lập; chưa wiring Aspire, Admin Web, domain workflows hoặc custom orchestration.

Audit và bằng chứng kiểm thử: [`ISOLATION.md`](ISOLATION.md).

## Yêu cầu và khởi chạy

Node.js **>=22.19.0** và npm; Python 3 trên Unix để chạy PTY smoke tests. Docker là tùy chọn cho container smoke tests. Chạy các lệnh trong `services/langfens-harness/`:

```bash
npm ci --ignore-scripts

# Chạy trực tiếp source TypeScript, mở TUI; không cần build trước
npm run dev

# Chạy source ở chế độ JSONL RPC
npm run dev -- --mode rpc --no-session

# Build và kiểm tra bản phân phối Node.js
npm run build:offline
npm run check
npm test
npm start
# Hoặc gọi trực tiếp local Node entrypoint, không qua executable pi trong PATH:
node scripts/run.mjs --mode rpc --no-session
```

- `npm ci` cài dependencies theo lockfile; không chạy lifecycle scripts.
- `npm run dev` chạy source; `npm start` chạy bản đã build. Cả hai qua isolation launcher, luôn `--offline` qua environment; chưa có watch/hot reload.
- `scripts/run.mjs` spawn bằng `process.execPath` + đường dẫn CLI tuyệt đối. npm executable local `node_modules/.bin/pi` cũng đi qua launcher. Không dùng Pi global.
- Launcher đặt workspace riêng thay vì dùng thư mục gọi lệnh. Cần build lại để bản compiled nhận thay đổi source.
- Build dùng model catalog đã lưu trong source, không tải hoặc sinh lại catalog.
- `npm run check` chạy TypeScript typecheck.
- `npm test` chạy smoke tests với faux stream/provider có sẵn của Pi và chặn kết nối mạng.
- `--offline` tắt tải tự động/cập nhật catalog, **không** phải sandbox và **không** ngăn inference nếu người dùng gửi prompt với credentials hợp lệ.

## Runtime directories và SDK

Mặc định: `<harness>/.runtime/`. Đổi toàn bộ vị trí bằng `LANGFENS_HARNESS_RUNTIME_DIR=/absolute/path`; trong Docker là `/var/lib/langfens-harness`.

| Vị trí | Mục đích |
| --- | --- |
| `agent/` | Settings, auth, models, extensions, skills, prompts, themes |
| `sessions/` | Session storage |
| `packages/{npm,git}/` | Managed packages; `agent/{npm,git}` là symlink/junction nội bộ |
| `workspace/` | Working directory riêng, project `.pi` và context files |
| `home/` | HOME, user skills `.agents`, XDG configuration/cache |
| `bin/pi` | POSIX compatibility shim về local launcher |

Launcher ghi đè `PI_CODING_AGENT_DIR`, `PI_PACKAGE_DIR`, `PI_CODING_AGENT_SESSION_DIR`, `PI_SUBAGENTS_PI_CODING_AGENT_PACKAGE_ROOT`; không kế thừa các `PI_*`, `NODE_PATH` hoặc `NODE_OPTIONS` của host vào Pi child. Các biến provider API key vẫn được truyền nếu operator chủ động cung cấp; `--offline` không ngăn inference.

Để dùng SDK độc lập, preload isolation trước khi import SDK:

```bash
node --import ./scripts/register-runtime.mjs /absolute/path/to/local-sdk-entry.mjs
```

SDK entry phải nằm trong subsystem để Node resolve dependencies từ workspace. `register-runtime.mjs` chuyển cwd sang runtime workspace; dùng file URLs/absolute paths cho tài nguyên ứng dụng. Các file `packages/*/dist` là implementation entries, không phải isolation launcher; không chạy trực tiếp từ host environment chưa được cô lập. Child agents có thể chạy các implementation entries vì đã kế thừa environment riêng.

## Cấu trúc source

| Thư mục | Vai trò |
| --- | --- |
| `packages/agent/` | Agent execution loop, tool execution, state và cancellation |
| `packages/ai/` | Model providers, streaming, OAuth và model catalog |
| `packages/coding-agent/` | CLI, SDK, sessions/context, compaction, RPC và extensions |
| `packages/tui/` | Terminal UI và native platform support |
| `packages/telemetry/` | Telemetry contracts dùng bởi AI runtime |
| `packages/codemode/` | QuickJS sandbox và worker runtime |
| `packages/mcp/` | MCP client dùng bởi coding-agent |
| `scripts/` | Node bundle builder upstream |
| `test/` | Offline runtime smoke tests |

Dependency graph nội bộ:

```text
coding-agent -> agent, ai, codemode, mcp, tui
agent        -> ai
ai           -> telemetry
```

Package names, phiên bản dependencies và public APIs vẫn theo Pi. SDK entry là `@earendil-works/pi-coding-agent`; metadata `displayName` là `langfens-harness`.

Đã bỏ các packages không được runtime sử dụng (`chord`, `durable`, `env`, `evals`), tài liệu/examples/demos upstream, bộ test/fixtures/benchmarks upstream, CI/CD, Nix, Git hooks và release scripts. Native assets, themes, workers, HTML-export assets và `docs/codemode.md` vẫn được giữ vì phục vụ runtime. Các API trả đường dẫn tài liệu vẫn tồn tại, nhưng phần docs/examples đã bỏ không còn sẵn ở local; tham khảo upstream tại tag đã ghim.

42 provider JSON được lấy từ bản phân phối Pi 1.4.0 có sẵn, đối chiếu với source catalog và kèm hash manifest. Không sửa trực tiếp generated model declarations để thay đổi catalog.

## Tương thích pi-subagents

Project không cài hoặc đóng gói `pi-subagents`. Có thể kiểm tra một extension đã được cài riêng bằng đường dẫn tuyệt đối:

```bash
PI_SUBAGENTS_EXTENSION=/absolute/path/to/pi-subagents/bundle/index.js npm test
```

Smoke test tùy chọn kiểm tra alias loading, tool registration và startup/command discovery trên cả RPC bundled lẫn unbundled. Isolation test đọc riêng resolver từ artifact extension, kiểm tra cả parent CLI và SDK-host fallback, rồi thực thi executable đã chọn với `--version`. Resolver được đánh giá trong thư mục tạm, không import Pi global. Đây không phải dependency runtime của subsystem.

Không chạy agent prompts, workflows hoặc providers. Không đặt biến này thì hai kiểm tra external-extension được bỏ qua; RPC child spawning local, module resolution, config isolation và TUI PTY vẫn được kiểm tra bắt buộc.

## Docker

```bash
docker build -t langfens-harness:isolation-smoke .
npm run test:container

# RPC, stdin phải được giữ mở bởi caller:
docker run --rm --network none -i langfens-harness:isolation-smoke
# TUI:
docker run --rm --network none -it langfens-harness:isolation-smoke --no-session
```

Image build bằng `npm ci --ignore-scripts`, build/typecheck local, prune dev dependencies; chạy bằng Node với user `node`, không mount configuration/dependencies từ host. `.dockerignore` loại node_modules, dist, runtime và .env của host. `npm run test:container` kiểm tra image đã build, bao gồm TUI PTY; không build/pull/deploy image tự động.

Sẵn build với context là thư mục này để đăng ký container resource trong Aspire sau này. Hiện chỉ có CLI/RPC qua stdin/stdout, không có HTTP port hoặc health endpoint; RPC kết thúc khi stdin đóng. Aspire/caller tương lai cần quản lý stdin/lifecycle hoặc bổ sung transport trong task riêng.

## Phát triển

Đọc `AGENTS.md` trước khi chỉnh sửa. Không sửa generated `dist/` hoặc `node_modules/`; sửa source rồi build lại. Không thêm dependencies, đổi package names/public APIs hoặc tích hợp hạ tầng nếu chưa có yêu cầu rõ ràng.

## Bản quyền upstream

File `LICENSE` riêng đã được bỏ; thông báo MIT của Pi được giữ nguyên dưới đây. Việc đổi tên hoặc tối giản project không loại bỏ các điều kiện bản quyền upstream. Các thông báo bản quyền của mã bên thứ ba trong runtime vẫn phải được giữ.

```text
MIT License

Copyright (c) 2025 Mario Zechner

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
