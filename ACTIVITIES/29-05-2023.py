29-05-2023
#activity to create a BANKING APPLICATION

{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Group acativity"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# banking application\n",
    "    (Dena Bank)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 39,
   "metadata": {},
   "outputs": [],
   "source": [
    "attributes=['name','phone no','address','id','amount_deposited']\n",
    "# new_user=['saket',765478,\"bihar\",789,45]\n",
    "# c=zip(attributes,new_user)\n",
    "# print(list(c))\n",
    "\n",
    "\n",
    "user_data={}"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "from random import randint\n",
    "# acn=randint(100,500)\n",
    "# print(acn)\n",
    "def newuser():\n",
    "    acc_no=str(randint(1000000,9999999))\n",
    "    #print(acc_no)\n",
    "    new_user=[]\n",
    "    for i in range(len(attributes)):\n",
    "        new_user.append(input(f\"Enter your {attributes[i]} :\"))\n",
    "    user_details={i:j for i,j in zip(attributes,new_user)}\n",
    "    print(user_details)\n",
    "    user_data[acc_no]=user_details\n",
    "    print(\"Registered successfully\\n\",acc_no)    \n",
    "        \n",
    "   \n",
    "\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 74,
   "metadata": {},
   "outputs": [],
   "source": [
    "def old_user():\n",
    "    acc_no=input(\"Enter your  account No.\\n \")\n",
    "    while acc_no not in user_data.keys(): \n",
    "        print(\"user not found\")\n",
    "        break\n",
    "    user_info=user_data[acc_no]\n",
    "    usr_inpt=input(f\"Welcome,{user_info['name']}\\nEnter 1 to check balance\\n Enter 2 to deposit Money in Account\\n Enter 3 to withdraw\\n Enter 4 to Exit \")\n",
    "    if usr_inpt=='1':\n",
    "        print(\"Your balance is\",user_info['amount_deposited'])\n",
    "    if usr_inpt=='4':\n",
    "        exit()\n",
    "    \n",
    "        "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 75,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Enter your  account No.\n",
      " 5818350\n",
      "Welcome,saket\n",
      "Enter 1 to check balance\n",
      " Enter 2 to deposit Money in Account\n",
      " Enter 3 to withdraw\n",
      " Enter 4 to Exit 1\n",
      "Your balance is 25\n"
     ]
    }
   ],
   "source": [
    "old_user()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 62,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "dict_keys(['5818350'])"
      ]
     },
     "execution_count": 62,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "user_data.keys()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.9.6"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}