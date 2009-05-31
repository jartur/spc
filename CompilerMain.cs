using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace spc
{
    class CompilerMain
    {
        static void Main(string[] args)
        {
            using (StreamReader input = new StreamReader("test.pas"))
            {
                Lexer lexer = new Lexer(input);
                var tok = lexer.NextToken();
                while (tok != null)
                {
                    Console.WriteLine(tok.ToString());
                    tok = lexer.NextToken();
                }
            }
            Console.ReadLine();
        }
    }
}
