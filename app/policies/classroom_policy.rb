class ClassroomPolicy < ApplicationPolicy
  def index?
    case @user.role
    when 'admin'   then true
    when 'teacher' then @record.user_id == @user.id
    when 'student' then @record.students.include?(@user)
    else false
    end
  end

  def create?
    @user.teacher?
    %w[admin teacher].include?(@user.role) && user.teacher?
  end

  def update?
    case @user.role
    when 'admin'   then true
    when 'teacher' then @record.user_id == @user.id
    else false
    end
  end

  alias show? index?
  alias new? create?
  alias edit? update?
  alias destroy? update?

  class Scope < Scope
    def resolve
      case @user.role
      when 'admin'   then @scope.all
      when 'teacher' then @scope.where(user_id: @user.id)
      when 'student' then @scope.where(id: @user.classrooms.ids)
      else @scope.where(id: -1)
      end
    end
  end
end
