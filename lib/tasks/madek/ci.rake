namespace :madek do
  namespace :ci do
  
    desc "Updates and (creates when needed) all feature jobs; requires CI_USER and CI_PW env variables"
    task :create_or_update_all_feature_jobs do
      CIFeatureJobs.create_or_update_all_jobs!
    end

    desc "Checks if all features habe been built successfully" 
    task :query_all_features_success do
      last_job_builds = CIFeatureJobs.get_last_build_status_of_all_jobs
      if CIFeatureJobs.all_features_success? last_job_builds
        exit 0
      else
        puts last_job_builds.select{|h| not h[:is_success]}.to_yaml
        exit -1
      end
    end

  end
end
