describe Fastlane::Actions::UploadToOssAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The upload_to_oss plugin is working!")

      Fastlane::Actions::UploadToOssAction.run(nil)
    end
  end
end
