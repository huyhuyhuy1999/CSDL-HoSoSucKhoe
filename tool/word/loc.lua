-- Bộ lọc pandoc dùng khi xuất tài liệu Markdown trong docs/ sang Word.
--   1. <br> trong ô bảng thành ngắt dòng thật.
--   2. Liên kết tương đối được sửa lại cho đúng với vị trí docs/word/.
--   3. Ảnh được thu vừa trang; ảnh trong bảng chia đều theo số cột.
--   4. Độ rộng cột của bảng tỷ lệ với độ dài nội dung.

local RONG_TRANG_CM = 16.0  -- A4 trừ lề trái 3 cm và lề phải 2 cm
local CAO_TOI_DA_CM = 21.5
local DPI_SO_DO = 150       -- sơ đồ PlantUML được dựng ở 160 dpi

function RawInline(el)
  if el.format:match("html") and el.text:match("^<br%s*/?>$") then
    return pandoc.LineBreak()
  end
end

function Link(el)
  local dich = el.target
  if dich:match("^%a+://") or dich:match("^#") then
    return nil
  end
  if dich:match("^%d%d_[%w_]+%.md$") then
    el.target = dich:gsub("%.md$", ".docx")
  else
    el.target = "../" .. dich
  end
  return el
end

local function doc_anh(duong_dan)
  for _, thu_muc in ipairs(PANDOC_STATE.resource_path) do
    local tep = io.open(thu_muc .. "/" .. duong_dan, "rb")
    if tep then
      local du_lieu = tep:read("a")
      tep:close()
      return du_lieu
    end
  end
  return nil
end

function Image(el)
  local du_lieu = doc_anh(el.src)
  if not du_lieu then
    error("Không tìm thấy ảnh: " .. el.src)
  end
  local kich_thuoc = pandoc.image.size(du_lieu)
  local ty_le = kich_thuoc.height / kich_thuoc.width
  local rong = math.min(RONG_TRANG_CM, kich_thuoc.width / DPI_SO_DO * 2.54)
  if rong * ty_le > CAO_TOI_DA_CM then
    rong = CAO_TOI_DA_CM / ty_le
  end
  el.attributes.width = string.format("%.2fcm", rong)
  el.attributes.height = string.format("%.2fcm", rong * ty_le)
  return el
end

local function do_dai(s)
  return utf8.len(s) or #s
end

-- Số ký tự cỡ 11 xếp vừa một dòng rộng bằng trang, và phần đệm của mỗi ô.
local SUC_CHUA = 84
local DEM = 2

function Table(tbl)
  local so_cot = #tbl.colspecs
  local toi_thieu, toi_da = {}, {}
  local co_anh = false

  local function xet_dong(dong)
    for i, o in ipairs(dong.cells) do
      pandoc.walk_block(pandoc.Div(o.contents), {
        Image = function() co_anh = true end,
      })
      local chu = pandoc.utils.stringify(o.contents)
      toi_da[i] = math.max(toi_da[i] or 0, do_dai(chu))
      -- Word không ngắt giữa một từ, nên từ dài nhất quyết định độ rộng tối thiểu.
      for tu in chu:gmatch("%S+") do
        toi_thieu[i] = math.max(toi_thieu[i] or 0, do_dai(tu))
      end
    end
  end

  for _, dong in ipairs(tbl.head.rows) do xet_dong(dong) end
  for _, than in ipairs(tbl.bodies) do
    for _, dong in ipairs(than.body) do xet_dong(dong) end
  end

  if co_anh then
    -- Bảng ảnh chụp màn hình: các cột bằng nhau, ảnh vừa khít ô.
    local rong_o = (RONG_TRANG_CM - 0.4 * so_cot) / so_cot
    for i = 1, so_cot do
      tbl.colspecs[i][2] = 1 / so_cot
    end
    return pandoc.walk_block(tbl, {
      Image = function(anh)
        local h = tonumber((anh.attributes.height or ""):match("^([%d%.]+)cm$"))
        local w = tonumber((anh.attributes.width or ""):match("^([%d%.]+)cm$"))
        anh.attributes.width = string.format("%.2fcm", rong_o)
        if h and w then
          anh.attributes.height = string.format("%.2fcm", rong_o * h / w)
        end
        return anh
      end,
    })
  end

  -- Chia cột như trình duyệt chia bảng: mỗi cột nhận đủ chỗ cho từ dài nhất,
  -- phần còn lại chia theo lượng chữ của từng cột.
  local tong_thieu, tong_da = 0, 0
  for i = 1, so_cot do
    toi_thieu[i] = math.min(toi_thieu[i] or 1, 24) + DEM
    toi_da[i] = math.max(toi_thieu[i], math.min(toi_da[i] or 1, 60) + DEM)
    tong_thieu = tong_thieu + toi_thieu[i]
    tong_da = tong_da + toi_da[i]
  end

  local rong = {}
  local tong = 0
  for i = 1, so_cot do
    if tong_da <= SUC_CHUA then
      rong[i] = toi_da[i]
    elseif tong_thieu >= SUC_CHUA then
      rong[i] = toi_thieu[i]
    else
      rong[i] = toi_thieu[i]
        + (SUC_CHUA - tong_thieu) * (toi_da[i] - toi_thieu[i]) / (tong_da - tong_thieu)
    end
    tong = tong + rong[i]
  end
  for i = 1, so_cot do
    tbl.colspecs[i][2] = rong[i] / tong
  end

  -- Chữ trong bảng dùng kiểu riêng (cỡ 11) để bảng nhiều cột không bị chật.
  local function boc(dong)
    for _, o in ipairs(dong.cells) do
      if #o.contents > 0 then
        -- pandoc luôn gán kiểu Compact cho khối Plain trong bảng, nên đổi sang Para
        -- để kiểu riêng có hiệu lực.
        local khoi = {}
        for _, b in ipairs(o.contents) do
          khoi[#khoi + 1] = b.t == "Plain" and pandoc.Para(b.content) or b
        end
        o.contents = { pandoc.Div(khoi, pandoc.Attr("", {}, { ["custom-style"] = "Noi Dung Bang" })) }
      end
    end
  end
  for _, dong in ipairs(tbl.head.rows) do boc(dong) end
  for _, than in ipairs(tbl.bodies) do
    for _, dong in ipairs(than.body) do boc(dong) end
  end
  return tbl
end
