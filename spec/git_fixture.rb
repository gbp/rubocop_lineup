# frozen_string_literal: true

require "tmpdir"
require "git"
require "securerandom"

class GitFixture
  attr_reader :git

  def make_temp_repo
    root_tmp_dir = File.expand_path("../tmp", __dir__)
    FileUtils.mkpath root_tmp_dir
    Dir.mktmpdir("test_repo_#{SecureRandom.hex(2)}", root_tmp_dir) do |dir|
      @dir = dir
      Git.init(dir)
      @git = Git.open(dir)
      Dir.chdir(dir) do
        yield dir
      end
    end
  end

  def write_file(filename, content)
    file_content = case content
                   when Array
                     Array(content).join("\n")
                   else
                     content
                   end
    File.open(File.join(@dir, filename), "w") { |f| f.puts file_content }
  end

  def delete_file(filename)
    FileUtils.rm filename
  end

  def commit_all(message = "test commit")
    @git.add(all: true)
    @git.commit(message, all: true)
  end

  def checkout_branch(branch)
    git.branch(branch).checkout
  end

  def setup_origin
    git.add_remote("origin", "url://")
  end
end
