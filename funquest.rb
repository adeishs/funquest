#!/usr/bin/env ruby
# frozen_string_literal: true

def gen_roots(min, max)
  rs = Array.new(2) { rand(min..max) } until (rs || []).uniq.size > 1
  rs.map { |x| [-1, 1].sample * x }
end

def gen_mult
  ([1] * 16 + [2] * 8 + [3]).sample
end

def gen_y0(num_of_questions)
  (1..num_of_questions).map do |i|
    {
      roots: gen_roots(1 + ((i - 1) * 1.25).to_i, i * 2).sort,
      mults: Array.new(2) { gen_mult }
    }
  end
end

def calc_coeff(param)
  mm = param[:mults].reduce(:*)
  {
    a: mm,
    b: -mm * param[:roots].sum,
    c: mm * param[:roots].reduce(:*)
  }
end

def calc_extremum(coeff)
  x = 0.5 * -coeff[:b] / coeff[:a]
  Complex.new(x, coeff[:a] * (x**2) + coeff[:b] * x + coeff[:c])
end

def gen_questions(num_of_questions)
  gen_y0(num_of_questions).map do |p|
    coeff = calc_coeff(p)
    {
      **p,
      **coeff,
      extremum: calc_extremum(coeff)
    }
  end
end

def sign_sym(num, neg_sym: '-', not_neg_sym: '+')
  num.negative? ? neg_sym : not_neg_sym
end

def sup_one(num)
  num.abs == 1 ? '' : num.abs.to_s
end

def fmt_function(question)
  format(
    '%<a>sx^2%<b>sx%<c>s',
    a: sign_sym(question[:a], not_neg_sym: '') + sup_one(question[:a]),
    b: sign_sym(question[:b]) + sup_one(question[:b]),
    c: sign_sym(question[:c]) + question[:c].abs.to_s
  )
end

srand
questions = gen_questions(10)
qstr = questions.map { |q| "\\item $f(x) = #{fmt_function(q)}$" }.join("\n")
sstr = questions.map do |q|
  format(
    '\item %<xs>s; Extremum: $(%<ext>s)$',
    xs: q[:roots].map { |r| "$x = #{r}$" }.join('; '),
    ext: q[:extremum].rect.map { |c| format('%<c>g', c: c) }.join(', ')
  )
end.join("\n")
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

  For each of these functions:
  \begin{itemize}
  \item Find the extremum.
  \item Find the solutions for $f(x) = 0$.
  \item Plot the graph.
  \end{itemize}

  \begin{enumerate}
OUT
puts qstr
puts <<~'OUT'
  \end{enumerate}

  \newpage

  \section*{Solutions}
  \begin{enumerate}
OUT
puts sstr
puts <<~'OUT'
  \end{enumerate}
  \end{document}
OUT
