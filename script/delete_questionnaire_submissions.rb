for id in @site.questionnaires.find_by_name("submit_your_story").questionnaire_submissions.collect{|aa| aa.id}
if (Hash[QuestionnaireSubmission.find(id).questions_and_answers].values_at("Name") - ["",nil]).blank?
  QuestionnaireSubmission.find(id).answers.collect{|aa| aa.delete}
  QuestionnaireSubmission.find(id).delete
end
end

for id in @site.questionnaires.find_by_name("submit_your_project").questionnaire_submissions.collect{|aa| aa.id}
if (Hash[QuestionnaireSubmission.find(id).questions_and_answers].values_at("Name") - ["",nil]).blank?
  QuestionnaireSubmission.find(id).answers.collect{|aa| aa.delete}
  QuestionnaireSubmission.find(id).delete
end
end

for id in @site.questionnaires.find_by_name("Advertise").questionnaire_submissions.collect{|aa| aa.id}
if (Hash[QuestionnaireSubmission.find(id).questions_and_answers].values_at("Name") - ["",nil]).blank?
  QuestionnaireSubmission.find(id).answers.collect{|aa| aa.delete}
  QuestionnaireSubmission.find(id).delete
end
end

for id in @site.questionnaires.find_by_name("Contact-us").questionnaire_submissions.collect{|aa| aa.id}
if (Hash[QuestionnaireSubmission.find(id).questions_and_answers].values_at("Name") - ["",nil]).blank?
  QuestionnaireSubmission.find(id).answers.collect{|aa| aa.delete}
  QuestionnaireSubmission.find(id).delete
end
end

for id in @site.questionnaires.find_by_name("Newsletter").questionnaire_submissions.collect{|aa| aa.id}
if (Hash[QuestionnaireSubmission.find(id).questions_and_answers].values_at("Name") - ["",nil]).blank?
  QuestionnaireSubmission.find(id).answers.collect{|aa| aa.delete}
  QuestionnaireSubmission.find(id).delete
end
end

for id in @site.questionnaires.find_by_name("Exhibit-with-us").questionnaire_submissions.collect{|aa| aa.id}
if (Hash[QuestionnaireSubmission.find(id).questions_and_answers].values_at("Name") - ["",nil]).blank?
  QuestionnaireSubmission.find(id).answers.collect{|aa| aa.delete}
  QuestionnaireSubmission.find(id).delete
end
end



Section--------------->dont delete    GET FEATURED

