using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace spc
{
    class SourcePosition
    {
        public int Row { get; set; }
        public int Column { get; set; }

        public SourcePosition()
        {
            Row = 1;
            Column = 1;
        }

        public SourcePosition(int row, int col)
        {
            Row = row;
            Column = col;
        }

        public override string ToString()
        {
            return string.Format("({0},{1})", Row, Column);
        }
    }

    class Token
    {
        public SourcePosition Position { get; set; }
        public string Literal { get; set; }

        protected Token(SourcePosition pos, string literal)
        {
            Position = pos;
            Literal = literal;
        }

        public override string ToString()
        {
            return string.Format("{0,-10}{1,-15}", Position, Literal);
        }
    }

    class TokenInt : Token
    {
        public int Value { get; set; }

        public TokenInt(SourcePosition pos,
                        string literal,
                        int val)
            : base(pos, literal)
        {
            Value = val;
        }

        public override string ToString()
        {
            return string.Format("{0}{1,-20}{2,-20}", base.ToString(), "Integer", Value);
        }
    }

    class TokenReal : Token
    {
        public double Value { get; set; }

        public TokenReal(SourcePosition pos,
                         string literal,
                         double val)
            : base(pos, literal)
        {
            Value = val;
        }

        public override string ToString()
        {
            return string.Format("{0}{1,-20}{2,-20}", base.ToString(), "Real", Value);
        }
    }

    class TokenId : Token
    {
        public string Value { get; private set; }

        public TokenId(SourcePosition pos,
                       string literal)
            : base(pos, literal)
        {
            Value = literal.ToUpper();
        }

        public override string ToString()
        {
            return string.Format("{0}{1,-20}{2,-20}", base.ToString(), "Identificator", Value);
        }
    }
// TODO make keywords & symbols enums maybe? It should speed the lexer up somewhat. Not sure though.
    class TokenKeyword : Token
    {
        public string Value { get; private set; }

        public TokenKeyword(SourcePosition pos,
                            string literal)
            : base(pos, literal)
        {
            Value = literal.ToUpper();
        }

        public override string ToString()
        {
            return string.Format("{0}{1,-20}{2,-20}", base.ToString(), "Keyword", Value);
        }
    }

    class TokenSymbol : Token
    {
        public string Value { get; private set; }

        public TokenSymbol(SourcePosition pos,
                           string literal)
            : base(pos, literal)
        {
            Value = literal;
        }

        public override string ToString()
        {
            return string.Format("{0}{1,-20}{2,-20}", base.ToString(), "Symbol", Value);
        }
    }

    class TokenString : Token
    {
        public string Value { get; private set; }

        public TokenString(SourcePosition pos,
                           string literal)
            : base(pos, literal)
        {
            Value = literal.Substring(1, literal.Length - 2);
            Value = Value.Replace("''", "'");
        }

        public override string ToString()
        {
            return string.Format("{0}{1,-20}{2,-20}", base.ToString(), "String", Value);
        }
    }
}
