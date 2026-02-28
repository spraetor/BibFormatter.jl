"""Map of journal macros to full journal names."""
const journalNames = Dict(
  "acmcs" => "ACM Computing Surveys",
  "acta" => "Acta Informatica",
  "cacm" => "Communications of the ACM",
  "ibmjrd" => "IBM Journal of Research and Development",
  "ibmsj" => "IBM Systems Journal",
  "ieeese" => "IEEE Transactions on Software Engineering",
  "ieeetc" => "IEEE Transactions on Computers",
  "ieeetcad" => "IEEE Transactions on Computer-Aided Design of Integrated Circuits",
  "ipl" => "Information Processing Letters",
  "jacm" => "Journal of the ACM",
  "jcss" => "Journal of Computer and System Sciences",
  "scp" => "Science of Computer Programming",
  "sicomp" => "SIAM Journal on Computing",
  "tocs" => "ACM Transactions on Computer Systems",
  "tods" => "ACM Transactions on Database Systems",
  "tog" => "ACM Transactions on Graphics",
  "toms" => "ACM Transactions on Mathematical Software",
  "toois" => "ACM Transactions on Office Information Systems",
  "toplas" => "ACM Transactions on Programming Languages and Systems",
  "tcs" => "Theoretical Computer Science",
)

"""Map of journal macros to abbreviated journal names."""
const journalAbbrv = Dict(
  "acmcs" => "ACM Comput. Surv.",
  "acta" => "Acta Inf.",
  "cacm" => "Commun. ACM",
  "ibmjrd" => "IBM J. Res. Dev.",
  "ibmsj" => "IBM Syst.~J.",
  "ieeese" => "IEEE Trans. Softw. Eng.",
  "ieeetc" => "IEEE Trans. Comput.",
  "ieeetcad" => "IEEE Trans. Comput.-Aided Design Integrated Circuits",
  "ipl" => "Inf. Process. Lett.",
  "jacm" => "J.~ACM",
  "jcss" => "J.~Comput. Syst. Sci.",
  "scp" => "Sci. Comput. Programming",
  "sicomp" => "SIAM J. Comput.",
  "tocs" => "ACM Trans. Comput. Syst.",
  "tods" => "ACM Trans. Database Syst.",
  "tog" => "ACM Trans. Gr.",
  "toms" => "ACM Trans. Math. Softw.",
  "toois" => "ACM Trans. Office Inf. Syst.",
  "toplas" => "ACM Trans. Prog. Lang. Syst.",
  "tcs" => "Theoretical Comput. Sci.",
)

"""Replace a journal token with its abbreviated display form."""
replaceJournalAbbrv(str::String) = empty(str) ? "" : get(journalAbbrv, str, str)
"""Replace a journal token with its full display form."""
replaceJournalNames(str::String) = empty(str) ? "" : get(journalNames, str, str)
