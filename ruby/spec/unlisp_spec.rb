require 'unlisp'
require 'spec_helper'

describe Unlisp do
  it 'has a version number' do
    expect(Unlisp::VERSION).not_to be nil
  end

  describe Unlisp::Lexer do
    it '1 is Integer' do
      one = Unlisp::Lexer::tokenize '1'
      int = Unlisp::Lexer::Token::INTEGER
      expect(one.type).to eq(int)
      expect(one.value).to eq(1)
    end

    it '"string" is String' do
      s = Unlisp::Lexer::tokenize '"String"'
      str = Unlisp::Lexer::Token::STRING
      expect(s.type).to eq(str)
      expect(s.value).to eq("String")
    end

    it 'atom is Atom' do
      a = Unlisp::Lexer::tokenize 'atom'
      atom = Unlisp::Lexer::Token::ATOM
      expect(a.type).to eq(atom)
      expect(a.value).to eq('atom')
    end

    it '+ is Atom' do
      a = Unlisp::Lexer::tokenize '+'
      atom = Unlisp::Lexer::Token::ATOM
      expect(a.type).to eq(atom)
      expect(a.value).to eq('+')
    end

    it '"" is Error' do
      e = Unlisp::Lexer::tokenize ''
      error = Unlisp::Lexer::Token::ERROR
      expect(e.type).to eq(error)
    end

    it '[] is List' do
      l = Unlisp::Lexer::tokenize []
      lst = Unlisp::Lexer::Token::LIST
      expect(l.type).to eq(lst)
      expect(l.value).to eq([])
    end

    it '["+", "1", "1"] is [ATOM, INTEGER, INTEGER]' do
      l = Unlisp::Lexer::list_analyzer ["+", "1", "1"]
      expect(l[0].type).to eq(Unlisp::Lexer::Token::ATOM)
      expect(l[1].type).to eq(Unlisp::Lexer::Token::INTEGER)
      expect(l[2].type).to eq(Unlisp::Lexer::Token::INTEGER)
    end

    it '["+", ["+", "1", "1"] "1"] is [ATOM, LIST=[ATOM INT INT] INT]' do
      l = Unlisp::Lexer::list_analyzer ["+", ["+", "1", "1"], "1"]
      expect(l[1].type).to eq(Unlisp::Lexer::Token::LIST)
      expect(l[1].value[0].type).to eq(Unlisp::Lexer::Token::ATOM)
      expect(l[1].value[1].type).to eq(Unlisp::Lexer::Token::INTEGER)
      expect(l[1].value[2].type).to eq(Unlisp::Lexer::Token::INTEGER)
    end
  end
end
