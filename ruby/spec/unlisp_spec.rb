require 'unlisp'
require 'spec_helper'

describe Unlisp do
  it 'has a version number' do
    expect(Unlisp::VERSION).not_to be nil
  end

  describe Unlisp::Lexer do
    it '1 is Integer' do
      one = Unlisp::Lexer::tokenize '1'
      int = Unlisp::Token::INTEGER
      expect(one.type).to eq(int)
      expect(one.value).to eq(1)
    end

    it 'atom is Atom' do
      a = Unlisp::Lexer::tokenize 'atom'
      atom = Unlisp::Token::ATOM
      expect(a.type).to eq(atom)
      expect(a.value).to eq('atom')
    end

    it '+ is Atom' do
      a = Unlisp::Lexer::tokenize '+'
      atom = Unlisp::Token::ATOM
      expect(a.type).to eq(atom)
      expect(a.value).to eq('+')
    end

    it '"" is Error' do
      e = Unlisp::Lexer::tokenize ''
      error = Unlisp::Token::ERROR
      expect(e.type).to eq(error)
    end

    it '[] is List' do
      l = Unlisp::Lexer::tokenize []
      lst = Unlisp::Token::LIST
      expect(l.type).to eq(lst)
      expect(l.value).to eq([])
    end

    it '["+", "1", "1"] is [ATOM, INTEGER, INTEGER]' do
      l = Unlisp::Lexer::list_analyzer ["+", "1", "1"]
      expect(l[0].type).to eq(Unlisp::Token::ATOM)
      expect(l[1].type).to eq(Unlisp::Token::INTEGER)
      expect(l[2].type).to eq(Unlisp::Token::INTEGER)
    end

    it '["+", ["+", "1", "1"] "1"] is [ATOM, LIST=[ATOM INT INT] INT]' do
      l = Unlisp::Lexer::list_analyzer ["+", ["+", "1", "1"], "1"]
      expect(l[1].type).to eq(Unlisp::Token::LIST)
      expect(l[1].value[0].type).to eq(Unlisp::Token::ATOM)
      expect(l[1].value[1].type).to eq(Unlisp::Token::INTEGER)
      expect(l[1].value[2].type).to eq(Unlisp::Token::INTEGER)
    end
  end

  describe Unlisp::Parser do
    def analyze_and_eval lst
      env = Unlisp::Env.new
      lst = Unlisp::Lexer::list_analyzer lst
      psr, env = Unlisp::Parser::list_eval lst, env
      return env, lst, psr
    end

    it '["+", "1", "1"] is 2' do
      env, lst, psr = analyze_and_eval ["+", "1", "1"]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(2)
    end

    it '["+", ["+", "1", "1"], "1"] is 3' do
      env, lst, psr = analyze_and_eval ["+", ["+", "1", "1"], "1"]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(3)
    end

    it '["do" ["+" "1" "1"] ["+" "2" "2"]] return last eval token' do
      env, lst, psr = analyze_and_eval ["do", ["+", "1", "1"], ["+", "2", "2"]]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(4)
    end

    it '["do" ["def", "x", "1"] ["+", "x", "x"]] results 2' do
      env, lst, psr = analyze_and_eval ["do", ["def", "x", "1"], ["+", "x", "x"]]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
    end

    it '[["fn", "x", ["+", "x", "1"]], "6"] is 7' do
      env, lst, psr = analyze_and_eval [["fn", "x", ["+", "x", "1"]], "6"]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(7)
    end

    it '[[["fn", "x", ["fn", "y", ["+", "x", "y"]]], "2"], "3"] is 5' do
      env, lst, psr = analyze_and_eval [[["fn", "x", ["fn", "y", ["+", "x", "y"]]], "2"], "3"]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(5)
    end

    it '["<", ["+", "1", "2"], "5"] is 1' do
      env, lst, psr = analyze_and_eval ["<", ["+", "1", "2"], "5"]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(1)
    end

    it '["if", ["<", "3", "2"], ["+", "x", "x"], ["+", "2", "2"]] is 4' do
      env, lst, psr = analyze_and_eval ["if",
                                        ["<", "3", "2"],
                                        ["+", "x", "x"],
                                        ["+", "2", "2"]]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(4)
    end

    it '["do", ["def", "plus_one", ["fn", "x", ["+", "x", "1"]]], ["plus_one", ["+", "1", "1"]] is 3' do
      env, lst, psr = analyze_and_eval ["do",
                                        ["def", "plus_one",
                                         ["fn", "x", ["+", "x", "1"]]],
                                        ["plus_one", ["+", "1", "1"]]]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(3)
    end

    it '["do", ["def", "upto", ["fn", "x", ["if", ["<", "x", "10"], ["upto", ["+", "x", "1"]] "x"]]], ["upto", "5"]]] is 10' do
      env, lst, psr = analyze_and_eval ["do",
                                        ["def", "upto",
                                         ["fn", "x",
                                          ["if",
                                           ["<", "x", "10"],
                                           ["upto", ["+", "x", "1"]], "x"]]],
                                        ["upto", "5"]]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(10)
    end

    it '["do", ["def", "closure", [["fn", "x",["fn", "y", ["+", "x", "y"]]], "5"]], ["closure", "2"]] is 7' do
      env, lst, psr = analyze_and_eval ["do",
                                        ["def", "closure",
                                         [["fn", "x",["fn", "y", ["+", "x", "y"]]], "5"]],
                                        ["closure", "2"]]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(7)
    end

    it '["do", ["def","f", ["fn","n",["n",["n","2"]]]], ["f", ["fn", "x", ["+", "1", "x"]]]] is 4' do
      env, lst, psr = analyze_and_eval ["do",
                                        ["def","f", ["fn","n",["n",["n","2"]]]],
                                        ["f", ["fn", "x", ["+", "1", "x"]]]]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(4)
    end

    it 'fib 6 is 13' do
      env, lst, psr = analyze_and_eval ["do", [
                  "def", "fib",
                  ["fn", "n",
                   ["if", ["=", "n", "0"], "0",
                    ["if", ["=", "n", "1"], "1",
                     ["+", ["fib", ["-", "n", "1"]], ["fib", ["-", "n", "2"]]]]]]], ["fib", "7"]]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(13)
    end

    it 'fib 6 by 2times results same' do
      env, lst, psr = analyze_and_eval ["do", [
                  "def", "fib",
                  ["fn", "n",
                   ["if", ["=", "n", "0"], "0",
                    ["if", ["=", "n", "1"], "1",
                     ["+", ["fib", ["-", "n", "1"]], ["fib", ["-", "n", "2"]]]]]]], ["fib", "7"], ["fib", "7"]]
      expect(psr.type).to eq(Unlisp::Token::INTEGER)
      expect(psr.value).to eq(13)
    end
  end
end
