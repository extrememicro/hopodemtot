class Comment < ActiveRecord::Base
  include Flaggable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  acts_as_votable
  has_ancestry touch: true

  attr_accessor :as_moderator, :as_administrator

  validates :body, presence: true
  validates :user, presence: true
  validates_inclusion_of :commentable_type, in: ["Debate", "Proposal"]

  validates :alignment, inclusion: { in: -1..1 }, unless: :parent_id
  validates :alignment, presence: false, if: :parent_id

  validate :validate_body_length

  belongs_to :commentable, -> { with_hidden }, polymorphic: true, counter_cache: true
  belongs_to :user, -> { with_hidden }

  before_save :calculate_confidence_score

  before_destroy :dereference

  scope :for_render, -> { with_hidden.includes(user: :organization) }
  scope :with_visible_author, -> { joins(:user).where("users.hidden_at IS NULL") }
  scope :not_as_admin_or_moderator, -> { where("administrator_id IS NULL").where("moderator_id IS NULL")}
  scope :sort_by_flags, -> { order(flags_count: :desc, updated_at: :desc) }

  scope :sort_by_most_voted , -> { order(confidence_score: :desc, created_at: :desc) }
  scope :sort_descendants_by_most_voted , -> { order(confidence_score: :desc, created_at: :asc) }

  scope :sort_by_newest, -> { order(created_at: :desc) }
  scope :sort_descendants_by_newest, -> { order(created_at: :desc) }

  scope :sort_by_oldest, -> { order(created_at: :asc) }
  scope :sort_descendants_by_oldest, -> { order(created_at: :asc) }

  after_create :call_after_commented

  after_initialize do |comment| 
    comment.alignment ||= 0 unless comment.parent_id
  end

  def self.build(commentable, user, params = {})
    new({commentable: commentable, user_id:     user.id}.merge(params))
  end

  def self.find_commentable(c_type, c_id)
    c_type.constantize.find(c_id)
  end

  def self.positive
    where(arel_table[:alignment].gt 0)
  end

  def self.negative
    where(arel_table[:alignment].lt 0)
  end

  def self.neutral
    where(arel_table[:alignment].eq 0)
  end

  def author_id
    user_id
  end

  def author
    user
  end

  def author=(author)
    self.user= author
  end

  def total_votes
    cached_votes_total
  end

  def total_likes
    cached_votes_up
  end

  def total_dislikes
    cached_votes_down
  end

  def as_administrator?
    administrator_id.present?
  end

  def as_moderator?
    moderator_id.present?
  end

  def after_hide
    commentable_type.constantize.with_hidden.reset_counters(commentable_id, :comments)
  end

  def after_restore
    Referrer.new(self, self.commentable).reference!(body)
    commentable_type.constantize.with_hidden.reset_counters(commentable_id, :comments)
  end

  def reply?
    !root?
  end

  def call_after_commented
    self.commentable.try(:after_commented)
  end

  def self.body_max_length
    1000
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(cached_votes_total,
                                                             cached_votes_up)
  end

  def arguable?
    false
  end

  private

    def validate_body_length
      unless Ability.new(user).can?(:write_long, self)
        validator = ActiveModel::Validations::LengthValidator.new(
          attributes: :body,
          maximum: Comment.body_max_length)
        validator.validate(self)
      end
    end

    def dereference
      Referrer.new(self, self.commentable).dereference!
    end

end
