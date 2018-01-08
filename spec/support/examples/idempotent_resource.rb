shared_examples 'an idempotent resource' do
    it 'runs without errors' do
      apply_manifest(@manifest, catch_failures: true)
    end
  
    it 'runs a second time without changes' do
      apply_manifest(@manifest, catch_changes: true)
    end
  end