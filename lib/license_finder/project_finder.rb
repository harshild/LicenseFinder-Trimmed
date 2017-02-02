module LicenseFinder
  class ProjectFinder
    def initialize(main_project_path)
      @package_managers = LicenseFinder::PackageManager.package_managers
      @main_project_path = main_project_path
    end

    def find_projects
      project_paths = []
      all_paths = find_all_paths
      until all_paths.empty?
        project_paths << collect_project_path(all_paths)
        all_paths.shift
      end
      project_paths.compact
    end

    def collect_project_path(all_paths)
      potential_project_path = all_paths.first
      if active_project?(potential_project_path)
        remove_nested(potential_project_path, all_paths)
        return potential_project_path.to_s
      end
    end

    private

    def find_all_paths
      Dir.glob("#{@main_project_path}/**/").map { |path| full_path(path) }
    end

    def remove_nested(pathname, paths)
      return if project_root?(pathname)
      paths.reject! { |path| nested_path?(path, pathname) }
    end

    def project_root?(pathname)
      full_path(@main_project_path).to_s == pathname.to_s
    end

    def active_project?(project_path)
      active_project = @package_managers.map do |pm|
        pm.new(project_path: project_path).active?
      end
      active_project.include?(true)
    end

    def full_path(rel_path)
      Pathname.new(rel_path).expand_path
    end

    def nested_path?(path, pathname)
      (path.to_s).start_with?(pathname.to_s) && path.to_s != pathname.to_s
    end
  end
end
