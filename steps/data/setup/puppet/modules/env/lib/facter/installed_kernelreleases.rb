Facter.add(:installed_kernelreleases) do
  setcode do
    kernels = Dir.glob('/boot/{vmlinuz,vmlinux}-*')

    kernels.sort_by! do |k|
      m = /^\/boot\/vmlinu[zx]-(\d+)\.(\d+)\.(\d+)(_|-)(\d+).*$/.match(k)
      [m[1].to_i, m[2].to_i, m[3].to_i, m[5].to_i]
    end

    kernels.map { |k| k.gsub(/\/boot\/vmlinu[zx]-(\d+\.\d+\.\d+(_|-)\d+.*)/, '\1') }
  end
end
