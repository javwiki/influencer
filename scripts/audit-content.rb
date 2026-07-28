#!/usr/bin/env ruby

require "yaml"

ROOT = File.expand_path("..", __dir__)
LIST_PATH = File.join(ROOT, "src/_meta/list.yaml")
PLACEHOLDER_PATTERNS = [
  /活跃于影视圈/,
  /活跃于韩剧圈/,
  /活跃于写真界/,
  /活跃于泰国影视圈/
].freeze
REFERENCE_HEADING = /^## (参考资料|相关链接|社交媒体|外部链接)\s*$/

errors = []
metadata = YAML.load_file(LIST_PATH)
entries = metadata.fetch("entries")
seen_paths = {}

entries.each do |entry|
  relative_path = entry.fetch("path")
  profile_path = File.join(ROOT, "src", relative_path)

  if seen_paths.key?(relative_path)
    errors << "重复索引路径：#{relative_path}"
  else
    seen_paths[relative_path] = true
  end

  unless File.file?(profile_path)
    errors << "索引文件不存在：#{relative_path}"
    next
  end

  content = File.binread(profile_path).force_encoding("UTF-8")
  errors << "#{relative_path} 不是有效 UTF-8" unless content.valid_encoding?
  errors << "#{relative_path} 包含 CR/CRLF 换行" if content.include?("\r")

  tag = content[/^tags:\s*\[([^\]]+)\]/, 1]
  verification = content[/^verification:\s*(pending|partial|verified)$/, 1]
  region = content[/^\| 地区 \| ([^|]+) \|$/, 1]
  status = content[/^\| 资料状态 \| ([^|]+) \|$/, 1]
  expected_status = {
    "pending" => "待核验",
    "partial" => "部分核验",
    "verified" => "已核验"
  }[verification]

  errors << "#{relative_path} 缺少或错误的 tags" unless tag
  errors << "#{relative_path} 的标签与索引不一致" unless entry["tags"] == [tag]
  errors << "#{relative_path} 缺少 verification" unless verification
  errors << "#{relative_path} 缺少地区字段" unless region
  errors << "#{relative_path} 缺少资料状态" unless status
  if status && expected_status && !status.start_with?(expected_status)
    errors << "#{relative_path} 的 verification 与资料状态不一致"
  end
  errors << "#{relative_path} 的资料表被空行截断" if content.match?(/^\| 分类 \|[^\n]*\|\n\n+\| 地区 \|/m)

  reference_sections = content.split(/(?=^## )/).select do |section|
    section.lines.first&.match?(REFERENCE_HEADING)
  end
  reference_sections.each do |section|
    unless section.match?(%r{https?://})
      errors << "#{relative_path} 的参考资料章节没有可访问链接"
    end
  end
  if verification == "verified" &&
     reference_sections.none? { |section| section.match?(%r{https?://}) }
    errors << "#{relative_path} 标为 verified，但缺少带链接的参考资料章节"
  end

  score = 60
  score += 15 unless content.include?("待补充核实") ||
                     PLACEHOLDER_PATTERNS.any? { |pattern| content.match?(pattern) }
  score += 10 if content.match?(/[12][0-9]{3}年/)
  score += 15 if content.match?(%r{https?://})

  if entry["completeness"] != score
    errors << "#{relative_path} 完整度应为 #{score}，实际为 #{entry['completeness']}"
  end
end

indexed_paths = seen_paths.keys.sort
profile_paths = Dir.glob(File.join(ROOT, "src/[A-Z]/*.md"))
                   .reject { |path| File.basename(path) == "README.md" }
                   .map { |path| path.delete_prefix(File.join(ROOT, "src/")) }
                   .sort

(profile_paths - indexed_paths).each { |path| errors << "资料未加入索引：#{path}" }
(indexed_paths - profile_paths).each { |path| errors << "索引包含非资料文件：#{path}" }

if errors.empty?
  puts "内容审查通过：#{entries.length} 个条目"
else
  warn errors.join("\n")
  exit 1
end
