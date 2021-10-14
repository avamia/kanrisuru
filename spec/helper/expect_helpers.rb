# frozen_string_literal: true

def expect_command(result, string)
  expect(result.command.raw_command).to eq(
    string
  )
end