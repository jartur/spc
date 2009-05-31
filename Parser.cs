using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace spc
{
    class Parser
    {
        Lexer lexer;
        Token current;

        public Parser()
        {
            program();
        }

        private void program()
        {
            block();
            symbol(".");
        }

        private void block()
        {
            if (current is TokenKeyword)
            {
                var kw = current as TokenKeyword;

                switch (kw.Value)
                {
                    case "LABEL":
                        integerList();
                        symbol(";");
                        block();
                        break;
                    case "CONST":
                        constDeclList();
                        block();
                        break;
                    case "TYPE":
                        typeDeclList();
                        block();
                        break;
                    case "VAR":
                        varDeclList();
                        block();
                        break;
                    case "PROCEDURE":
                        identifier();
                        paramList();
                        symbol(";");
                        block();
                        symbol(";");
                        block();
                        break;
                    case "FUNCTION":
                        identifier();
                        paramList();
                        symbol(":");
                        typeIdentifier();
                        symbol(";");
                        block();
                        symbol(";");
                        block();
                        break;
                    case "BEGIN":
                        statementList();
                        keyword("end");
                        break;
                    default:
                        break;
                }
            }
        }

        private void integerList() 
        {
            integer();
            symbol(",");
            integerList();
        }

        private void integer()
        {
        }

        private void constDeclList() 
        {
            identifier();
            symbol("=");
            constant();
            symbol(";");
            constDeclList();
        }

        private void constant()
        {
        }

        private void typeDeclList() 
        {
            identifier();
            symbol("=");
            type();
            symbol(";");
            typeDeclList();
        }

        private void type()
        {
        }

        private void varDeclList() 
        {
            identifierList();
            symbol(":");
            type();
            symbol(";");
            varDeclList();
        }

        private void identifierList()
        {
        }

        private void identifier() 
        { 
        }

        private void paramList() 
        {
 
        }

        private void typeIdentifier() { }
        private void statementList() 
        {
            statement();
            symbol(";");
            statementList();
        }

        private void statement() 
        {
            if (current is TokenInt)
            {
                symbol(":");
            }

            if (current is TokenId)
            {
                if (variable(current as TokenId) || funcId(current as TokenId))
                {
                    symbol(":=");
                    expression();
                }
                else if (procId(current as TokenId))
                {
                    procCallList();
                }
            }
        }

        private void procCallList()
        {
            //fixme
            symbol("(");
            while (expression() || procId(current as TokenId))
            {
                symbol(",");
            }
            symbol(")");
        }

        private bool expression() { return true;  }

        private bool procId(TokenId tok)
        {
            return true;
        }

        private bool variable(TokenId tok)
        {
            return true;
        }

        private bool funcId(TokenId tok)
        {
            return true;
        }

        private void keyword(string kw) { }

        private void symbol(string sym)
        {
        }
    }
}
