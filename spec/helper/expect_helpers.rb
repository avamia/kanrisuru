# frozen_string_literal: true

def expect_command(result, string)
  # puts result.command.raw_command
  expect(result.command.raw_command).to eq(
    string
  )
end
