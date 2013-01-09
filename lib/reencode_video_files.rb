def reencode(me)

  me.media_file.previews.destroy_all
  me.media_file.submit_encoding_job(true)
  me.reload
  while !me.media_file.encode_job_finished?
    sleep 60
  end
  me.media_file.assign_video_thumbnails_to_preview
  me.media_file.assign_audio_previews

end
