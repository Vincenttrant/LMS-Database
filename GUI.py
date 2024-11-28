from tkinter import *
from tkinter import ttk
import sqlite3
from datetime import datetime, timedelta

# Initialize Tkinter
root = Tk()
root.title('Library Management System')
root.geometry("500x500")

# Connect to the DB
conn = sqlite3.connect('project2.db')
print("Connected to DB Successfully")

# Functions to toggle visibility of frames
def show_checkout_frame():
    hide_all_frames()
    checkout_frame.pack(pady=10)

def show_add_borrower_frame():
    hide_all_frames()
    add_borrower_frame.pack(pady=10)

def show_add_book_frame():
    hide_all_frames()
    add_book_frame.pack(pady=10)

def hide_all_frames():
    checkout_frame.pack_forget()
    add_borrower_frame.pack_forget()
    add_book_frame.pack_forget()

def CheckOutBookBTN():
    submit_conn = sqlite3.connect('project2.db')
    submit_cur = submit_conn.cursor()

    # Get current date and due date 1 month from current date
    date_out = datetime.now().date()
    due_date = date_out + timedelta(days=30)

    # Insert data into BOOK_LOANS table (Trigger will handle BOOK_COPIES update)
    submit_cur.execute(
        """
        INSERT INTO BOOK_LOANS (book_id, branch_id, card_no, date_out, due_date, returned_date)
        VALUES (?, ?, ?, ?, ?, NULL)
        """,
        (book_id.get(), branch_id.get(), card_no.get(), date_out, due_date)
    )

    # Fetch the updated row from BOOK_COPIES
    submit_cur.execute(
        """
        SELECT book_id, branch_id, no_of_copies
        FROM BOOK_COPIES
        WHERE book_id = ? AND branch_id = ?
        """,
        (book_id.get(), branch_id.get())
    )

    # Commit transaction
    submit_conn.commit()

    showBookCopies()

    submit_conn.close()

# Display BOOK_COPIES data
def showBookCopies():
    # Clear previous Treeview content
    for widget in checkout_frame.winfo_children():
        widget.destroy()

    conn = sqlite3.connect('project2.db')
    cur = conn.cursor()

    cur.execute("SELECT * FROM BOOK_COPIES")
    rows = cur.fetchall()

    # Create Treeview widget
    tree = ttk.Treeview(checkout_frame, columns=("book_id", "branch_id", "no_of_copies"), show="headings", height=10)
    tree.pack(pady=10)

    # Define column headings
    tree.heading("book_id", text="Book ID")
    tree.heading("branch_id", text="Branch ID")
    tree.heading("no_of_copies", text="No of Copies")

    # Set column widths
    tree.column("book_id", anchor=CENTER, width=100)
    tree.column("branch_id", anchor=CENTER, width=100)
    tree.column("no_of_copies", anchor=CENTER, width=150)

    for row in rows:
        tree.insert("", "end", values=row)

    conn.commit()
    conn.close()

# Function to add a borrower
def AddBorrowerBTN():
    submit_conn = sqlite3.connect('project2.db')
    submit_cur = submit_conn.cursor()
    
    # Generate a new card number by adding 1 to the current max
    submit_cur.execute("SELECT MAX(card_no) FROM BORROWER")
    max_card_no = submit_cur.fetchone()[0]
    new_card_no = (max_card_no + 1) if max_card_no else 1

    # Insert the new borrower into the BORROWER table
    submit_cur.execute(
        """
        INSERT INTO BORROWER (card_no, name, address, phone)
        VALUES (?, ?, ?, ?)
        """,
        (new_card_no, borrower_name.get(), borrower_address.get(), borrower_phone.get())
    )

    submit_conn.commit()
    submit_conn.close()
    
    # Clear the textboxes after submission
    # borrower_card_no.delete(0, END)
    borrower_name.delete(0, END)
    borrower_address.delete(0, END)
    borrower_phone.delete(0, END)

    # Show the card number
    Label(add_borrower_frame, text=f"Card Number: {new_card_no}").grid(row=5, column=0, columnspan=2, pady=10)


# Function to add a book
def AddBookBTN():
    submit_conn = sqlite3.connect('project2.db')
    submit_cur = submit_conn.cursor()
    
    # TODO
    
    # Insert the new book into the BOOK table
    submit_cur.execute(
        """
        INSERT INTO BOOK (book_id, title, publisher_name)
        VALUES (?, ?, ?)
        """,
        (book_id.get(), book_title.get(), publisher_name.get())
    )

    # Insert the new author into the BOOK_AUTHORS table
    submit_cur.execute(
        """
        INSERT INTO BOOK_AUTHORS (book_id, author_name)
        VALUES (?, ?)
        """,
        (book_id.get(), author_name.get())
    )
    
    submit_conn.commit()
    submit_conn.close()

    # Clear the textboxes after submission
    book_id.delete(0, END)
    book_title.delete(0, END)

# Frames for different actions
checkout_frame = Frame(root)
add_borrower_frame = Frame(root)
add_book_frame = Frame(root)

# Checkout frame inputs
Label(checkout_frame, text="Book ID").grid(row=0, column=0, padx=10, pady=5)
book_id = Entry(checkout_frame, width=30)
book_id.grid(row=0, column=1, padx=10, pady=5)

Label(checkout_frame, text="Branch ID").grid(row=1, column=0, padx=10, pady=5)
branch_id = Entry(checkout_frame, width=30)
branch_id.grid(row=1, column=1, padx=10, pady=5)

Label(checkout_frame, text="Card No").grid(row=2, column=0, padx=10, pady=5)
card_no = Entry(checkout_frame, width=30)
card_no.grid(row=2, column=1, padx=10, pady=5)

Button(checkout_frame, text="Submit Book", command=CheckOutBookBTN).grid(row=3, column=0, columnspan=2, pady=10)


# Add Borrower frame inputs
Label(add_borrower_frame, text="Borrower Name").grid(row=0, column=0, padx=10, pady=5)
borrower_name = Entry(add_borrower_frame, width=30)
borrower_name.grid(row=0, column=1, padx=10, pady=5)

Label(add_borrower_frame, text="Borrower Address").grid(row=1, column=0, padx=10, pady=5)
borrower_address = Entry(add_borrower_frame, width=30)
borrower_address.grid(row=1, column=1, padx=10, pady=5)

Label(add_borrower_frame, text="Borrower Phone").grid(row=2, column=0, padx=10, pady=5)
borrower_phone = Entry(add_borrower_frame, width=30)
borrower_phone.grid(row=2, column=1, padx=10, pady=5)

Button(add_borrower_frame, text="Submit New Borrower", command=AddBorrowerBTN).grid(row=4, column=0, columnspan=2, pady=10)


# Add Book frame inputs
Label(add_book_frame, text="Book ID").grid(row=0, column=0, padx=10, pady=5)
book_id = Entry(add_book_frame, width=30)
book_id.grid(row=0, column=1, padx=10, pady=5)

Label(add_book_frame, text="Book Title").grid(row=1, column=0, padx=10, pady=5)
book_title = Entry(add_book_frame, width=30)
book_title.grid(row=1, column=1, padx=10, pady=5)

Label(add_book_frame, text="Book Publisher").grid(row=2, column=0, padx=10, pady=5)
publisher_name = Entry(add_book_frame, width=30)
publisher_name.grid(row=2, column=1, padx=10, pady=5)

Label(add_book_frame, text="Book Author").grid(row=3, column=0, padx=10, pady=5)
author_name = Entry(add_book_frame, width=30)
author_name.grid(row=3, column=1, padx=10, pady=5)

Button(add_book_frame, text="Submit New Book", command=AddBookBTN).grid(row=4, column=0, columnspan=2, pady=10)


# Navigation buttons
Button(root, text="Check Out Book", command=show_checkout_frame).pack(pady=5)
Button(root, text="Add Borrower", command=show_add_borrower_frame).pack(pady=5)
Button(root, text="Add Book", command=show_add_book_frame).pack(pady=5)

root.mainloop()