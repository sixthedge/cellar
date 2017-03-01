# Clear asset cache during development server startup
if Rails.env.development? && ( tmp = File.join(Rails.root, 'tmp/cache/assets') ) && Dir.exist?(tmp)
  puts "[info] Removing and Creating Path=#{tmp.inspect}"
  FileUtils.remove_dir(tmp)
  FileUtils.mkpath(tmp)
end