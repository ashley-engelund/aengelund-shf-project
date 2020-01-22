FactoryBot.define do
  factory :admin_only_master_checklist_type, class: 'AdminOnly::MasterChecklistType' do
    name { "type name" }
    description { "description" }
  end
end
