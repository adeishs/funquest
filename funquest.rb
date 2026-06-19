#!/usr/bin/env ruby
# frozen_string_literal: true

def gen_roots(min, max)
  rs = Array.new(2) { rand(min..max) } until (rs || []).uniq.size > 1
  rs.map { |x| [-1, 1].sample * x }
end

def gen_mult
  ([1] * 16 + [2] * 8 + [3] * 2 + [4]).sample
end

def gen_solutions(num_of_questions)
  (1..num_of_questions).map do |i|
    {
      roots: gen_roots(1 + ((i - 1) * 1.25).to_i, i * 3),
      mults: Array.new(2) { gen_mult }
    }
  end
end

def gen_questions(num_of_questions)
  gen_solutions(num_of_questions).map do |p|
    mm = p[:mults].reduce(:*)
    {
      **p,
      a: mm,
      b: -mm * p[:roots].sum,
      c: mm * p[:roots].reduce(:*)
    }
  end
end

def sign_sym(num, neg_sym: '-', not_neg_sym: '+')
  num.negative? ? neg_sym : not_neg_sym
end

def sup_one(num)
  num.abs == 1 ? '' : num.abs.to_s
end

def fmt_question(question)
  format(
    'f(x) = %<a>sx^2%<b>sx%<c>s',
    a: sign_sym(question[:a], not_neg_sym: '') + sup_one(question[:a]),
    b: sign_sym(question[:b]) + sup_one(question[:b]),
    c: sign_sym(question[:c]) + question[:c].abs.to_s
  )
end

questions = gen_questions(10)
qstr = questions.map { |q| "\\item $#{fmt_question(q)}$" }.join("\n")
puts <<~'OUT'
  \documentclass[12pt, a4paper]{article}
  \usepackage[margin=3cm]{geometry}
  \usepackage{setspace}
  \onehalfspacing % Sets document line spacing to 1.5

  \title{Practice Questions}
  \author{}
  \date{\today}

  \begin{document}

  \maketitle

  For each of these functions, find the extremum and plot the graph.

  \begin{enumerate}
OUT
puts qstr
puts <<~'OUT'
  \end{enumerate}
  \end{document}
OUT
