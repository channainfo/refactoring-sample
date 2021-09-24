class Branch

  def with_user(user)
    branches = Branch.order(:degree)
    branches = branches.delete_if{|x| !user.access_branches.include?(x.id)} if user.role == 'editor'
    branches
  end

end