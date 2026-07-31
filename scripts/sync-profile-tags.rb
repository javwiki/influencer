#!/usr/bin/env ruby

require "yaml"

ROOT = File.expand_path("..", __dir__)
LIST_PATH = File.join(ROOT, "src/_meta/list.yaml")
metadata = YAML.load_file(LIST_PATH)

identity_rules = [
  ["演员", /演员|影视表演|舞台表演/],
  ["模特", /模特|写真偶像|グラビア/],
  ["歌手", /歌手|歌唱事业|音乐活动/],
  ["偶像", /(?<!写真)偶像|偶像团体/],
  ["声优", /声优|配音/],
  ["网红", /网红|内容创作者|YouTuber|TikTok|社交平台|直播主播|SOOP|AfreecaTV|Twitch/],
  ["Coser", /Cosplayer|コスプレイヤー|角色扮演/],
  ["主持人", /主持人|节目主持|广播艺人|日本主播/],
  ["舞者", /舞者|舞蹈演员/],
  ["作家", /作家|出版.*书|散文集|小说/],
  ["DJ", /\bDJ\b/],
  ["运动员", /运动员|职业摔角手|专业麻将选手/]
].freeze

metadata.fetch("entries").each do |entry|
  path = File.join(ROOT, "src", entry.fetch("path"))
  unless File.file?(path)
    warn "跳过缺失资料文件：#{entry.fetch('path')}"
    next
  end
  content = File.read(path)
  current = content[/^tags:\s*\[([^\]]+)\]/, 1].to_s.split(",").map(&:strip).reject(&:empty?)
  description = content[/## 简介\n\n(.+?)(?=\n\n## |\z)/m, 1].to_s
  region = content[/^\| 地区 \| ([^|]+) \|$/, 1]&.strip
  region = "中国" if region == "大陆"
  birth_year = content[/^\| 出生年份 \| ([12][0-9]{3})年 \|$/, 1]
  birth_year ||= description[/([12][0-9]{3})年/, 1]

  tags = current
  tags += identity_rules.filter_map { |tag, pattern| tag if description.match?(pattern) }
  tags << region if region
  tags << "#{birth_year}年" if birth_year
  tags = tags.uniq

  next if tags == current && !content[%r{^tags:\s*\[}]

  content = content.sub(/^tags:\s*\[[^\]]*\]$/, "tags: [#{tags.join(', ')}]")
  File.write(path, content)
  entry["tags"] = tags
end

File.write(LIST_PATH, YAML.dump(metadata))
