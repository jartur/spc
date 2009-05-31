using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace spc
{
    class Lexer
    {
        private List<string> keywords;
        private bool CheckKeyword(string val)
        {
            return keywords.Contains(val);
        }

        private StreamReader input;
        private SourcePosition pos;

        public Lexer(StreamReader inputStream)
        {
            keywords = new List<string>()
            {
                "program", "if", "then", "else", "case", "of",
                "repeat", "until", "while", "do", "for", "to",
                "downto", "begin", "end", "with", "goto", "const",
                "var", "type", "array", "record", "set", "file",
                "function", "procedure", "label", "packed", "div",
                "mod", "nil", "in"
            };

            input = inputStream;
            pos = new SourcePosition();

            foreach (var a in keywords)
            {
                Console.Write(a.Substring(1, 0));
            }
        }

        private int skipWhitespace()
        {
            int count = 0;
            while (Char.IsWhiteSpace((char)input.Peek()))
            {
                var c = (char)input.Read();
                if (c == '\n')
                {
                    pos.Row++; pos.Column = 0;
                }
                else
                {
                    pos.Column++;
                }
                count++;
            }
            return count;
        }

        private int skipComment()
        {
            int count = 0;
            if ((char)input.Peek() == '{')
            {
                input.Read();
                count++;
                char c;
                while ((c = (char)input.Read()) != '}')
                {
                    if (c == '\n')
                    {
                        pos.Row++;
                        pos.Column = 0;
                    }
                    else
                    {
                        pos.Column++;
                    }
                    count++;
                }
                pos.Column++;
            }
            return count;
        }

        private Token readNumber()
        {
            var result = new StringBuilder(8);
            var startPos = new SourcePosition(pos.Row, pos.Column);
            Token ret = null;

            // Read integer part
            while (Char.IsDigit((char)input.Peek()))
            {
                pos.Column++;
                result.Append((char)input.Read());
            }

            // Read real number
            if ((char)input.Peek() == '.')
            {
                pos.Column++;
                result.Append((char)input.Read());

                // Read decimal part
                while (Char.IsDigit((char)input.Peek()))
                {
                    pos.Column++;
                    result.Append((char)input.Read());
                }

                // Read exponent
                if (Char.ToUpper((char)input.Peek()) == 'E')
                {
                    pos.Column++;
                    result.Append((char)input.Read());

                    // Read exponent sign
                    if ((char)input.Peek() == '+' || (char)input.Peek() == '-')
                    {
                        pos.Column++;
                        result.Append((char)input.Read());
                    }

                    // Read exponent value
                    while (Char.IsDigit((char)input.Peek()))
                    {
                        pos.Column++;
                        result.Append((char)input.Read());
                    }
                }

                var r = result.ToString();
                ret = new TokenReal(startPos, r, double.Parse(r));
            }
            else
            {
                var r = result.ToString();
                ret = new TokenInt(startPos, r, int.Parse(r));
            }

            return ret;
        }

        private Token readIdentificator()
        {
            var result = new StringBuilder();
            var startPos = new SourcePosition(pos.Row, pos.Column);
            Token ret = null;

            while (Char.IsLetterOrDigit((char)input.Peek()))
            {
                pos.Column++;
                result.Append((char)input.Read());
            }

            var r = result.ToString();
            if (keywords.Contains(r))
            {
                ret = new TokenKeyword(startPos, r);
            }
            else
            {
                ret = new TokenId(startPos, r);
            }

            return ret;
        }

        private TokenString readString()
        {
            var startPos = new SourcePosition(pos.Row, pos.Column);
            var result = new StringBuilder();
            TokenString ret = null;

            if ((char)input.Peek() == '\'')
            {
                pos.Column++;
                result.Append((char)input.Read());

                while (!input.EndOfStream)
                {
                    var c = (char)input.Read();
                    pos.Column++;
                    result.Append(c);

                    if (c == '\'')
                    {
                        if ((char)input.Peek() != '\'')
                        {
                            break;
                        }
                        else
                        {
                            input.Read();
                            pos.Column++;
                            result.Append('\'');
                        }
                    }
                }

                ret = new TokenString(startPos, result.ToString());
            }

            return ret;
        }

        private TokenSymbol readSymbol()
        {
            var startPos = new SourcePosition(pos.Row, pos.Column);
            string result;
            TokenSymbol ret = null;

            char[] oneCharSymbols = { '+', '-', '*', '/', '|', '&', 
                                      '!', '=', '(', ')', '[', ']', 
                                      '.', ',', ';', '^' };

            if(oneCharSymbols.Contains((char)input.Peek()))
            {
                ret = new TokenSymbol(startPos, ((char)input.Read()).ToString());
            }
            else
            {
                var c = (char)input.Peek();
                if (c == '<')
                {
                    input.Read();
                    pos.Column++;
                    c = (char)input.Peek();
                    if (c == '=')
                    {
                        input.Read();
                        pos.Column++;
                        ret = new TokenSymbol(startPos, "<=");
                    }
                    else if (c == '>')
                    {
                        input.Read();
                        pos.Column++;
                        ret = new TokenSymbol(startPos, "<>");
                    }
                    else
                    {
                        ret = new TokenSymbol(startPos, "<");
                    }
                }
                else if (c == '>')
                {
                    input.Read();
                    pos.Column++;

                    if ((char)input.Peek() == '=')
                    {
                        input.Read();
                        pos.Column++;
                        ret = new TokenSymbol(startPos, ">=");
                    }
                    else
                    {
                        ret = new TokenSymbol(startPos, ">");
                    }
                }
                else if (c == ':')
                {
                    input.Read();
                    pos.Column++;
                    c = (char)input.Peek();
                    if (c == '=')
                    {
                        input.Read();
                        pos.Column++;
                        ret = new TokenSymbol(startPos, ":=");
                    }
                    else
                    {
                        ret = new TokenSymbol(startPos, ":");
                    }
                }
            }

            return ret;
        }

        public Token NextToken()
        {
            var curPosition = new SourcePosition(pos.Row, pos.Column);
            char c = (char)input.Peek();

            while (skipWhitespace() + skipComment() != 0) ;

            c = (char)input.Peek();
            if (Char.IsDigit(c))
            {
                return readNumber();
            }

            if (Char.IsLetter(c))
            {
                return readIdentificator();
            }

            if (c == '\'')
            {
                return readString();
            }

            var tok = readSymbol();
            if (tok != null)
            {
                return tok;
            }

            return null;
        }
    }
}
